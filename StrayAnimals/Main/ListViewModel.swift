//
//  ListViewModel.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import Combine

enum ListUpdateType {
    case reloadAll
    case append(indexPaths: [IndexPath])
}

final class ListViewModel {
        
    // 用 Set 存訂閱，避免重複的訂閱
    private var cancellables = Set<AnyCancellable>()
        
    // 網路工具
    private let webService: WebService
    private let imageLoader: ImageLoading
    
    // 頁面資料數量狀態
    lazy private var listQuery: StrayAnimalListQuery = StrayAnimalListQuery(top: pageSize)
    private var currentPage: Int = 1
    private var pageSize: Int = 10
    private var canLoadMore: Bool = true
    @Published private(set) var isLoading: Bool = false
    
    // MARK: - Input
    // 接收 ViewController 來的事件
    let viewdidLoad = PassthroughSubject<Void, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    private(set) var listItemViewModels: [ListCollectionViewItemViewModel] = []
    // PassthroughSubject 傳送單一「事件」
    let listUpdate = PassthroughSubject<ListUpdateType, Never>()

    
    init(startPage: Int,
         pageSize: Int,
         webService: WebService = WebService(),
         imageLoader: ImageLoading = ImageLoader(session: URLSession.shared)) {
        self.currentPage = startPage
        self.pageSize = pageSize
        self.webService = webService
        self.imageLoader = imageLoader
        bind()
    }
    
    private func bind() {
        // 當 viewController 進到 viewDidLoad 狀態，就去 load data
        viewdidLoad
            .sink { [weak self] in
                self?.getPetData()
            }
            .store(in: &cancellables)
        // 當 viewController 需要更多資料時
        loadMore
            .sink { [weak self] in
                if self?.isLoading != true {
                    self?.loadNextPage()
                }
            }
            .store(in: &cancellables)
    }
    // MARK: - PetData 相關
    private func getPetData() {
        
        isLoading = true
        
        webService.sendRequest(with: APIEndpoint.StrayAnimalList(query: listQuery))
            // 在主執行緒
            .receive(on: DispatchQueue.main)
            // 建立訂閱
            .sink { completion in
                
                self.isLoading = false
                
                switch completion {
                case .finished:
                    print("Request finished. Page is: \(self.currentPage)")
                case .failure(let error):
                    print("Request failed with: \(error)")
                }
                print(completion)
            } receiveValue: { [weak self] response in
                guard let self else { return }
                // 先抓取更新前的 count
                let oldCount = listItemViewModels.count
                // 更新 Array
                let cellViewModels = response.map { self.makeCellViewModel(for: $0) }
                listItemViewModels.append(contentsOf: cellViewModels)
                // 抓取更新的 Index
                let newCount = listItemViewModels.count
                let updateIndexPaths = (oldCount ..< newCount).map { IndexPath(row: $0, section: 0) }
                // 傳送更新事件
                if oldCount == 0 {
                    listUpdate.send(.reloadAll)
                } else {
                    listUpdate.send(.append(indexPaths: updateIndexPaths))
                }
            }
            // 把訂閱存起來，避免被自動取消
            .store(in: &cancellables)
    }
    
    private func loadNextPage() {
        // 更新頁數
        currentPage += 1
        listQuery.setPage(currentPage, size: pageSize)
        getPetData()
    }
    
    // MARK: - Cell 相關
    private func makeCellViewModel(for item: PetData) -> ListCollectionViewItemViewModel {
        ListCollectionViewItemViewModel(
            imageURL: URL(string: item.albumFile),
            kind: item.animalKind,
            sex: item.animalSex,
            status: item.animalStatus,
            age: item.animalAge,
            place: item.animalPlace,
            imageLoader: imageLoader
        )
    }
}
