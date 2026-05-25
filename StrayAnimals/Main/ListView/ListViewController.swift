//
//  ListViewController.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/8/30.
//

import UIKit
import Combine

class ListViewController: UIViewController {
    // MARK: - UI
    private let titleView: UILabel = {
        let label = UILabel()
        label.setTextAndImage(text: "流浪動物",
                              font: FontGroup.font(.bold, .large),
                              image: UIImage.paw,
                              imageArrangement: .left)
        return label
    }()
    
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
    /// 類別的 Item
    private let categoryCellRegistration = UICollectionView.CellRegistration<CategoryItem, CategoryItemViewModel> { cell, indexPath, viewModel in
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
        viewModel.input.viewdidLoad.send()
    }
    
    private func setUI() {
        view.backgroundColor = .viewBackground
        navigationItem.titleView = titleView
        
        view.addSubview(listCollectionView)
        listCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setBind() {
        // 選擇分類後更新 UI
        viewModel.output.setCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  in
                self?.applyCategoriesOnly()
            }
            .store(in: &cancellables)
        
        // 接收更新 List 事件
        viewModel.output.listUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateType in
                switch updateType {
                // 整個 List 重整
                case .reloadAll:
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
    case category   // 最上方類別，橫滑
    case petList    // 下方寵物列表，直滑
}
/// List Item 的種類
enum ListItem: Hashable {
    case category(id: Int)
    case petList(id: Int)
}

extension ListViewController {
    
    /// 綁定 CollectionView 的 Data Source
    private func configureDataSource() -> DataSource {
        // 這裡綁定這個 dataSource 是 listCollectionView
        return DataSource(collectionView: listCollectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return nil }
            
            switch item {
            case .category(let category):
                guard let item = viewModel.categoryViewModel.first(where: { $0.category.rawValue == category }) else { return nil }
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.categoryCellRegistration,
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
    }
    
    /// 整個 CollectionView 的 Layout
    private func makeCollectionLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self,
                  let section = ListSection(rawValue: sectionIndex)
            else { return nil }
            
            switch section {
            case .category:
                return self.makeCategorySection()
            case .petList:
                return self.makePetListSection()
            }
            
        }
    }
    /// 類別的 Layout
    private func makeCategorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            // estimated 預估值，absolute 固定值，fractionalWidth 相對父容器寬度的比例
            widthDimension: .estimated(80),
            heightDimension: .estimated(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .estimated(36)
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
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
        snapshot.appendSections([.category, .petList])
        
        let categoryItems = viewModel.categoryViewModel
        snapshot.appendItems(categoryItems.map { ListItem.category(id: $0.category.rawValue) }, toSection: .category)
        
        let petlistItems = viewModel.petViewModels
        snapshot.appendItems(petlistItems.map { ListItem.petList(id: $0.id) }, toSection: .petList)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    /// 只更新分類
    private func applyCategoriesOnly() {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(viewModel.categoryViewModel.map { ListItem.category(id: $0.category.rawValue) })
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
        case .category(let id):
            guard let category = ListCategory(rawValue: id) else { return }
            viewModel.input.categorySelected.send(category)
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
