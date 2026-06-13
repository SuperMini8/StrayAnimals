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
    case append(newItems: [PetListItemViewModel])
}

final class ListViewModel {
        
    // 用 Set 存訂閱，避免重複的訂閱
    private var cancellables = Set<AnyCancellable>()
        
    // 網路工具
    private let webService: APIClientProtocol
    private let imageLoader: ImageLoading
    
    // 類別
    private(set) var categoryViewModel: [CategoryItemViewModel] = []
    private(set) var currentCategory: ListCategory = .all
    
    // 頁面資料狀態
    private var pets: [PetData] = []
    private(set) var petViewModels: [PetListItemViewModel] = []
    lazy private var listQuery: StrayAnimalListQuery = StrayAnimalListQuery(top: pageSize)
    private var currentPage: Int = 1
    private var pageSize: Int = 10
    
    // Loading 狀態
    @Published private(set) var isLoading: Bool = false
    // 是否可以再載入下一頁
    private(set) var canLoadMore: Bool = true
    
    // MARK: - Input
    struct Intput {
        let viewdidLoad = PassthroughSubject<Void, Never>()
        let loadMore = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let categorySelected = PassthroughSubject<ListCategory, Never>()
        let petSelected = PassthroughSubject<Int, Never>()
    }
    
    let input = Intput()
    
    // MARK: - Output
    struct Output {
        // PassthroughSubject 傳送單一「事件」
        /// 更新分類畫面 (舊分類, 新分類)
        let setCategory = PassthroughSubject<Void, Never>()
        let listUpdate = PassthroughSubject<ListUpdateType, Never>()
        let errorMessage = PassthroughSubject<String, Never>()
        // 取得 Data 前往詳細頁
        let pushInformationView = PassthroughSubject<PetData, Never>()
    }
    
    let output = Output()
    
    init(startPage: Int,
         pageSize: Int,
         webService: APIClientProtocol = WebService(),
         imageLoader: ImageLoading = ImageLoader.shared) {
        self.currentPage = startPage
        self.pageSize = pageSize
        self.webService = webService
        self.imageLoader = imageLoader
        bind()
    }
    
    private func bind() {
        // 當 viewController 進到 viewDidLoad 狀態，就去 load data
        input.viewdidLoad
            .sink { [weak self] in
                self?.loadCategoryList()
                self?.getPetData(updateType: .reloadAll)
            }
            .store(in: &cancellables)
        // 當 viewController 需要更多資料時
        input.loadMore
            .sink { [weak self] in
                if self?.isLoading != true {
                    self?.loadNextPage()
                }
            }
            .store(in: &cancellables)
        input.reload
            .sink { [weak self] in
                if self?.isLoading != true {
                    self?.getPetData(updateType: .reloadAll)
                }
            }
            .store(in: &cancellables)
        // 選擇分類時
        input.categorySelected
            .sink { [weak self] kind in
                self?.selectedCategoryAndUpdatedData(kind)
            }
            .store(in: &cancellables)
        // 選擇寵物時
        input.petSelected
            .sink { [weak self] petID in
                if let data = self?.getPetFullData(with: petID) {
                    self?.output.pushInformationView.send(data)
                }
            }
            .store(in: &cancellables)
    }
    // MARK: - PetData 相關
    private var getPetDataRequestCancellable: AnyCancellable?
    private func getPetData(updateType: ListUpdateType) {
        // 先檢查能不能再載下一頁
        guard canLoadMore else { return }
        isLoading = true
        // 取消先前的 request
        getPetDataRequestCancellable?.cancel()
        // 儲存新的 request
        getPetDataRequestCancellable = webService.sendRequest(with: APIEndpoint.StrayAnimalList(query: listQuery))
            // 在主執行緒
            .receive(on: DispatchQueue.main)
            // 建立訂閱
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    print("Request finished. Page is: \(self.currentPage)")
                case .failure(let error):
                    print("Request failed with: \(error)")
                    self.output.errorMessage.send(error.errorMassage())
                }
                print(completion)
            } receiveValue: { [weak self] response in
                guard let self else { return }
                let items = response.map { self.makePetListItemViewModel(for: $0) }
                // 先檢查是否為空陣列，若為空陣列視為最後一頁。
                if items.isEmpty {
                    canLoadMore = false
                    return
                }
                // 傳送更新事件
                switch updateType {
                case .reloadAll:
                    pets = response
                    petViewModels = items
                    output.listUpdate.send(.reloadAll)
                case .append(_):
                    pets.append(contentsOf: response)
                    petViewModels.append(contentsOf: items)
                    output.listUpdate.send(.append(newItems: items))
                }
            }
    }
    
    private func loadNextPage() {
        // 更新頁數
        currentPage += 1
        listQuery.setPage(currentPage, size: pageSize)
        getPetData(updateType: .append(newItems: []))
    }
    
    // MARK: - Category 相關
    func loadCategoryList() {
        categoryViewModel = ListCategory.allCases.compactMap { CategoryItemViewModel(categoryType: $0, isSelected: $0 == currentCategory) }
    }
    
    func selectedCategoryAndUpdatedData(_ category: ListCategory) {
        // 先更新分類狀態
        currentCategory = category
        loadCategoryList()
        output.setCategory.send()
        // 再請求資料
        canLoadMore = true
        listQuery.setCategory(category)
        currentPage = 1
        listQuery.setPage(currentPage, size: pageSize)
        getPetData(updateType: .reloadAll)
    }
    
    // MARK: - PetListItem 相關
    // 將 Data 轉換成 View Model
    private func makePetListItemViewModel(for item: PetData) -> PetListItemViewModel {
        PetListItemViewModel(
            id: item.animalId,
            imageURL: URL(string: item.albumFile),
            kind: item.animalKind,
            variety: item.animalVariety,
            sex: item.animalSex,
            status: item.animalStatus,
            age: item.animalAge,
            place: item.animalPlace,
            imageLoader: imageLoader
        )
    }
    // 取得完整資料
    private func getPetFullData(with id: Int) -> PetData? {
        return pets.first(where: { $0.animalId == id })
    }
}
