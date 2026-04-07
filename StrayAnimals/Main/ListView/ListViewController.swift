//
//  ListViewController.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/8/30.
//

import UIKit
import Combine

class ListViewController: UIViewController {
        
    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.setTextAndImage(text: "流浪動物",
                              font: FontGroup.font(.bold, .large),
                              image: UIImage.dogAndCat,
                              imageArrangement: .left)
        return label
    }()
    
    private lazy var listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        let itemWidth = (view.frame.size.width - 30) / 2
        let itemHeight = itemWidth * 1.5
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layout.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: ListCollectionViewItem.self)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: ListViewModel
    
    init(viewModel: ListViewModel = ListViewModel(startPage: 1, pageSize: 10)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarAppearance()
        setUI()
        setBind()
        viewModel.viewdidLoad.send()
    }
    
    private func setUI() {
        view.backgroundColor = .lightGrey240
        navigationItem.titleView = titleView
        
        view.addSubview(listCollectionView)
        listCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setBind() {
        // 接收更新 List 事件
        viewModel.listUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateType in
                switch updateType {
                // 整個 List 重整
                case .reloadAll:
                    self?.listCollectionView.reloadData()
                // 只更新新的資料
                case .append(let indexPaths):
                    self?.listCollectionView.performBatchUpdates {
                        self?.listCollectionView.insertItems(at: indexPaths)
                    }
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
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(message: errorMessage,
                                buttonTitle: "確認",
                                buttonAction: { _ in
                    self?.viewModel.reload.send()
                })
            }
            .store(in: &cancellables)
    }
    
    private func setNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .peach
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
}

extension ListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.listItemViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListCollectionViewItem.self, for: indexPath)
        let cellViewModel = viewModel.listItemViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        return cell
    }
    
}

extension ListViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// contentOffset 是左上角相對移動的數字
        let offsetY = scrollView.contentOffset.y
        /// 想偵測是否為最底部，還必須檢查上 frame Height
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        /// 應該也可以寫成 offsetY + frameHeight == contentHeight
        /// - 100 是「接近」底部的判斷，所以會多次觸發
        if offsetY > contentHeight - frameHeight - 100 {
            if viewModel.isLoading == false {
                viewModel.loadMore.send()
            }
        }
    }
}
