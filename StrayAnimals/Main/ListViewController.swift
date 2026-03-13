//
//  ListViewController.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/8/30.
//

import UIKit
import Combine

class ListViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
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
        collectionView.register(ListCollectionViewItem.self, forCellWithReuseIdentifier: ListCollectionViewItem.cellID)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    let viewModel = ListViewModel(startPage: 1, pageSize: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarAppearance()
        setUI()
        setBind()
        viewModel.viewdidLoad.send()
    }
    
    private func setUI() {
        view.backgroundColor = .whiteSmoke
        navigationItem.titleView = titleView
        
        view.addSubview(listCollectionView)
        listCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    func setBind() {
        // data 更新，就更新畫面
        viewModel.$pets.sink { [weak self] datas in
            self?.listCollectionView.reloadData()
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
        return viewModel.pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewItem.cellID, for: indexPath) as? ListCollectionViewItem else { return UICollectionViewCell() }
        cell.configure(vm: viewModel.pets[indexPath.row])
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
