//
//  ListViewController.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/8/30.
//

import UIKit
import Combine

class ListViewController: UIViewController {
    // Compositional Layout 裡 Header 使用的 kind，這裡沿用系統預設的 Section Header
    private enum SupplementaryKind {
        static let sectionHeader = UICollectionView.elementKindSectionHeader
    }
    // Decoration View 是 section 背後的背景，不是 cell 或 header 本身
    private enum DecorationKind {
        static let todaySectionBackground = "today-section-background"
    }

    // MARK: - UI
    private let titleView: UILabel = {
        let label = UILabel()
        label.setTextAndImage(text: "浪浪想找家",
                              font: FontGroup.font(.bold, .large),
                              image: UIImage.paw,
                              imageArrangement: .left)
        return label
    }()
        
    private lazy var categoryFilterView = CategoryView()
    
    private lazy var listCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    typealias DataSource = UICollectionViewDiffableDataSource<ListSection, ListItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ListSection, ListItem>
    private lazy var dataSource: DataSource = configureDataSource()
    // 不可以在 provider 裡建立 registration，會 crash
    /// Today 的 Item
    private let todayPetCellRegistration = UICollectionView.CellRegistration<TodayPetItem, TodayPetItemViewModel> { cell, indexPath, viewModel in
            cell.configure(with: viewModel)
    }
    /// List 的 Item
    private let petListCellRegistration = UICollectionView.CellRegistration<PetListItem, PetListItemViewModel> { cell, indexPath, viewModel in
            cell.configure(with: viewModel)
    }
    // MARK: - property
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: ListViewModel
    
    // MARK: - method
    init(viewModel: ListViewModel = ListViewModel(startPage: 1, pageSize: 10)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ListViewController init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarAppearance()
        setUI()
        setBind()
        viewModel.input.viewDidLoad.send()
    }
    
    private func setUI() {
        view.backgroundColor = .viewBackground
        navigationItem.titleView = titleView
        navigationItem.backButtonDisplayMode = .minimal
        
        view.addSubview(categoryFilterView)
        categoryFilterView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        view.addSubview(listCollectionView)
        listCollectionView.snp.makeConstraints { make in
            make.top.equalTo(categoryFilterView.snp.bottom).offset(8)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setBind() {
        // 綁定類別選擇後的事件傳送
        categoryFilterView.onFilterChanged = { [weak self] filter in
            self?.viewModel.input.filterChanged.send(filter)
        }
        // 接收今日更新橫滑區塊事件
        viewModel.output.todayListUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.applyTodayPetOnly()
            }
            .store(in: &cancellables)

        // 接收下方主要列表事件
        viewModel.output.listUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateType in
                switch updateType {
                    // List 重整
                case .reloadList:
                    self?.applySnapshot()
                    // 只更新新的資料
                case .append(let items):
                    self?.applyMorePetList(newPetItems: items)
                }
            }
            .store(in: &cancellables)
        
        // Loading 畫面
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showAnimated in
                // Loading View 開關
                showAnimated ? self?.showLoadingView() : self?.hideLoadingView()
            }
            .store(in: &cancellables)
        
        // error 事件
        viewModel.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(title: "網路錯誤",
                                message: errorMessage,
                                buttonTitle: "確認",
                                buttonAction: { _ in
                    self?.viewModel.input.reload.send()
                })
            }
            .store(in: &cancellables)
        // 選擇寵物後前往詳細頁
        viewModel.output.pushInformationView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] petData in
                print("選擇寵物：\(petData.animalId)，前往詳細頁")
                self?.pushInformationView(petData)
            }
            .store(in: &cancellables)
    }
    
    private func setNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .navigationBar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func pushInformationView(_ data: PetData) {
        let vcm = PetInformationViewModel(petData: data)
        let vc = PetInformationViewController(viewModel: vcm)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: - UICollectionView 相關
/// List Section 的種類
enum ListSection: Int, CaseIterable {
    case todayList  // 今日更新
    case petList    // 下方寵物列表，直滑
}
/// List Item 的種類
enum ListItem: Hashable {
    case todayList(id: Int)
    case petList(id: Int)
}

extension ListViewController {
    
    /// 綁定 CollectionView 的 Data Source
    private func configureDataSource() -> DataSource {
        // Header registration 要先建立好，不能等 supplementaryViewProvider 被呼叫時才建立
        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<ListSectionHeaderView>(
            elementKind: SupplementaryKind.sectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            // Header 也用目前 snapshot 找 section，避免 todayList 隱藏時 section index 對錯
            guard let section = self?.listSection(at: indexPath.section) else {
                supplementaryView.configure(title: nil)
                return
            }

            switch section {
            case .todayList:
                // 目前只有今日更新 section 需要 Header 文字
                supplementaryView.configure(title: "今日更新")
            default:
                supplementaryView.configure(title: nil)
            }
        }

        // 這裡綁定這個 dataSource 是 listCollectionView
        let dataSource = DataSource(collectionView: listCollectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return nil }
            
            switch item {
            case .todayList(let pet):
                guard let item = viewModel.todayPetsViewModels.first(where: { $0.id == pet }) else { return nil }
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.todayPetCellRegistration,
                    for: indexPath,
                    item: item
                )
                
            case .petList(let pet):
                guard let item = viewModel.petViewModels.first(where: { $0.id == pet }) else { return nil }
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.petListCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        }

        // 提供 section header。只有 layout 有設定 boundarySupplementaryItems 的 section 會來拿 header
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            guard elementKind == SupplementaryKind.sectionHeader else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: sectionHeaderRegistration,
                for: indexPath
            )
        }

        return dataSource
    }
    
    /// 整個 CollectionView 的 Layout
    private func makeCollectionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self,
                  // sectionIndex 是畫面目前第幾個 section，不一定等於 ListSection.rawValue
                  // 因為「今日更新」沒有資料時會整個 section 不顯示
                  let section = self.listSection(at: sectionIndex)
            else { return nil }
            
            switch section {
            case .todayList:
                return self.makeTodayPetSection()
            case .petList:
                return self.makePetListSection()
            }
            
        }
        // 註冊今日更新 section 背景，給 NSCollectionLayoutDecorationItem 使用
        layout.register(
            TodaySectionBackgroundView.self,
            forDecorationViewOfKind: DecorationKind.todaySectionBackground
        )
        return layout
    }

    /// 用目前 snapshot 找 section，避免 todayList 隱藏後 sectionIndex 對錯 layout
    private func listSection(at index: Int) -> ListSection? {
        let sections = dataSource.snapshot().sectionIdentifiers
        guard sections.indices.contains(index) else {
            // 初次建立 layout 時 snapshot 可能還是空的，先用 enum rawValue 作為預設
            return ListSection(rawValue: index)
        }
        return sections[index]
    }
    /// today 的 Layout
    private func makeTodayPetSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            // 今日更新卡片固定 180 x 180，橫滑時大小比較穩定
            widthDimension: .absolute(180),
            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // item 向內縮，讓圖片和背景色之間保留距離
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180),
            heightDimension: .absolute(180)
        )
        // 這裡一個 group 只放一個 item，所以 item 與 group 同大小
        // .horizontal 這個 group 為 水平排列
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        // 與 Collection View 主要滑行方向垂直 ex: CV 直滑此 section 可以設定橫滑
        // 預設值為 .none（不垂直的意思）.continuous 垂直後平順的滑
        section.orthogonalScrollingBehavior = .continuous
        // group 與 group 之間的間距
        section.interGroupSpacing = 8
        // section 上下 8 + item 上下 4，讓文字到圖片、圖片到底色底部的距離比較接近
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(32)
        )
        // Header 放在 today section 最上方，用來顯示「今日更新」
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: SupplementaryKind.sectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]

        // DecorationItem 會畫在整個 section 背後，所以背景色會跟著 section 一起出現
        let sectionBackground = NSCollectionLayoutDecorationItem.background(
            elementKind: DecorationKind.todaySectionBackground
        )
        // 背景色左右到底，不跟 cell 的左右 inset 走
        sectionBackground.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.decorationItems = [sectionBackground]
        
        return section
    }

    /// List 的 Layout
    private func makePetListSection() -> NSCollectionLayoutSection {
        // itemSize 是在設定 item 在 group 裡的大小，父視圖會是 group
        let itemSize = NSCollectionLayoutSize(
            // fractionalWidth、fractionalHeight 根據父視圖的比例
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // contentInsets 根據 itemSize 後再向內縮的間距
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        
        let groupSize = NSCollectionLayoutSize(
            // group 的 父視圖會是 collectionView
            widthDimension: .fractionalWidth(1.0),
            // 這裡設定高度為 item.width * 1.6
            // 因 item width 為 .fractionalWidth(0.5) 所以再 * 1.6
            heightDimension: .fractionalWidth(0.5 * 1.6)
        )
        // group 是在設定一組的大小，.horizontal 為 group 垂直排列
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            // group 裡要顯示的 item
            subitem: item,
            // 一個 group 顯示 item 的數量
            count: 2
        )
        
        let section = NSCollectionLayoutSection(group: group)
        // contentInsets 整個 section 再內縮的間距
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        return section
    }
    
    /// reload 時的 Snapshot
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        let todayItems = viewModel.todayPetsViewModels
        // 今日更新沒有資料時，不加入 todayList section；Header 和背景色也就不會先顯示
        let sections: [ListSection] = todayItems.isEmpty ? [.petList] : [.todayList, .petList]
        snapshot.appendSections(sections)
        
        if sections.contains(.todayList) {
            // 只有 todayList section 存在時，才可以把 today item append 進去
            snapshot.appendItems(todayItems.map { ListItem.todayList(id: $0.id) }, toSection: .todayList)
        }
        
        let petlistItems = viewModel.petViewModels
        snapshot.appendItems(petlistItems.map { ListItem.petList(id: $0.id) }, toSection: .petList)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    /// 只更新「今日更新」
    private func applyTodayPetOnly() {
        var snapshot = dataSource.snapshot()
        let todayItems = viewModel.todayPetsViewModels

        if todayItems.isEmpty {
            // 今日更新回空資料時，把整個 section 移除，避免留下背景色或 Header
            if snapshot.sectionIdentifiers.contains(.todayList) {
                snapshot.deleteSections([.todayList])
                dataSource.apply(snapshot, animatingDifferences: true)
            }
            return
        }

        guard snapshot.sectionIdentifiers.contains(.todayList) else {
            // 今日更新比主要列表晚回來時，在 petList 前插入 todayList section
            if snapshot.sectionIdentifiers.contains(.petList) {
                snapshot.insertSections([.todayList], beforeSection: .petList)
            } else {
                // 防呆：如果 petList 還不存在，就先把 todayList 加在最後
                snapshot.appendSections([.todayList])
            }
            snapshot.appendItems(todayItems.map { ListItem.todayList(id: $0.id) }, toSection: .todayList)
            dataSource.apply(snapshot, animatingDifferences: true)
            return
        }

        // todayList 已存在時，先刪掉舊資料，再塞入 API 回來的新資料
        let oldItems = snapshot.itemIdentifiers(inSection: .todayList)
        snapshot.deleteItems(oldItems)
        snapshot.appendItems(todayItems.map { ListItem.todayList(id: $0.id) }, toSection: .todayList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    /// 加入新的 Pet Data
    private func applyMorePetList(newPetItems: [PetListItemViewModel]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(newPetItems.map { ListItem.petList(id: $0.id) }, toSection: .petList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
// MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    // 選擇 Item 時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 直接獲取 Item 的 內容物（用 ID 辨別）
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .todayList(let id):
            viewModel.input.petSelected.send(id)
        case .petList(let id):
            viewModel.input.petSelected.send(id)
        }
    }
    
    // 接近底部載入更多
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// contentOffset 是左上角相對移動的數字
        let offsetY = scrollView.contentOffset.y
        /// 想偵測是否為最底部，還必須檢查上 frame Height
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        /// 應該也可以寫成 offsetY + frameHeight == contentHeight
        /// - 100 是「接近」底部的判斷，所以會多次觸發
        if offsetY > contentHeight - frameHeight - 100 {
            if viewModel.isLoading == false && viewModel.canLoadMore {
                viewModel.input.loadMore.send()
            }
        }
    }
}
