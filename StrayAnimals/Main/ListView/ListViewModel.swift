//
//  ListViewModel.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import Combine

enum ListUpdateType {
    // 下方主要列表重整
    case reloadList
    // 下方主要列表載入下一頁
    case append(newItems: [PetListItemViewModel])
}

final class ListViewModel {
        
    // 用 Set 存訂閱，避免重複的訂閱
    private var cancellables = Set<AnyCancellable>()
        
    // 網路工具
    private let webService: APIClientProtocol
    private let imageLoader: ImageLoading
        
    // 頁面資料狀態
    // 上面今日更新的 List 原始資料，點擊 TodayCell 時會用它進詳細頁
    private var todayPets: [PetData] = []
    // 上面今日更新的 List 畫面資料
    private(set) var todayPetsViewModels: [TodayPetItemViewModel] = []
    // 下面全部的 List
    private var pets: [PetData] = []
    private(set) var petViewModels: [PetListItemViewModel] = []
    lazy private var listQuery: StrayAnimalListQuery = StrayAnimalListQuery(top: pageSize)
    // 目前的篩選條件
    private var currentFilter = AnimalListFilter()
    // 目前已 load 的頁碼
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
        let filterChanged = PassthroughSubject<AnimalListFilter, Never>()
        let petSelected = PassthroughSubject<Int, Never>()
    }
    
    let input = Intput()
    
    // MARK: - Output
    struct Output {
        // PassthroughSubject 傳送單一「事件」
        // 今日更新橫滑區塊重整
        let todayListUpdate = PassthroughSubject<Void, Never>()
        // 下方主要列表重整或載入下一頁
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
                self?.getTodayPetData()
                self?.getPetData(updateType: .reloadList)
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
                guard let self = self else { return }
                if self.isLoading != true {
                    switch currentPage {
                    // 如果是第一頁，pets 又是空的，代表畫面是沒有資料的
                    case 1 where pets.isEmpty:
                        self.getPetData(updateType: .reloadList)
                    default:
                        loadNextPage()
                    }
                }
            }
            .store(in: &cancellables)
        // 更新篩選條件時，回到第一頁重新抓主要列表
        input.filterChanged
            .removeDuplicates()
            .sink { [weak self] filter in
                self?.applyFilterAndReload(filter)
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
    /// 取得「今日更新」資料，最多10 筆
    private func getTodayPetData() {
        // API 的 animal_update 格式是 yyyy/MM/dd，所以這裡用今天日期組查詢字串
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: .now)
        // 今日更新獨立打一支 request，不影響下方主要列表的分頁狀態
        webService.sendRequest(with: StrayAnimalList(query: .init(top: 10, animalUpdate: dateString)))
            .receive(on: DispatchQueue.main)
            .sink {[weak self] completion in
                guard self != nil else { return }
                switch completion {
                case .finished:
                    print("getTodayPetData Request finished.")
                case .failure(let error):
                    print("getPetData Request failed with: \(error)")
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                // 保留完整 PetData，讓使用者點 TodayCell 時可以直接進詳細頁
                self.todayPets = response
                // 轉成 TodayCell 需要的輕量 ViewModel
                self.todayPetsViewModels = response.map { self.makeTodayPetItemViewModel(for: $0) }
                output.todayListUpdate.send()
            }
            .store(in: &cancellables)
    }
    
    private var getPetDataRequestCancellable: AnyCancellable?
    private func getPetData(updateType: ListUpdateType) {
        // 先檢查能不能再載下一頁（如果更新是加入，並且不能 load more，就不 request）
        if case .append = updateType, !canLoadMore { return }
        isLoading = true
        // 取消先前的 request
        getPetDataRequestCancellable?.cancel()
        // 儲存新的 request
        getPetDataRequestCancellable = webService.sendRequest(with: StrayAnimalList(query: listQuery))
            // 在主執行緒
            .receive(on: DispatchQueue.main)
            // 建立訂閱
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    print("getPetData Request finished. Page is: \(self.currentPage)")
                case .failure(let error):
                    print("getPetData Request failed with: \(error)")
                    self.output.errorMessage.send(error.errorMassage())
                    if case .append = updateType {
                        canLoadMore = true
                        currentPage = max(1, currentPage - 1)
                        listQuery.setPage(currentPage, size: pageSize)
                    }
                }
                print(completion)
            } receiveValue: { [weak self] response in
                guard let self else { return }
                let items = response.map { self.makePetListItemViewModel(for: $0) }
                // 空陣列視為「最後一頁」
                if items.isEmpty {
                    canLoadMore = false
                }
                // 傳送更新事件
                switch updateType {
                case .reloadList:
                    pets = response
                    petViewModels = items
                    output.listUpdate.send(.reloadList)
                case .append:
                    // 如果加入是空資料就不用通知 UI 更新
                    if items.isEmpty {
                        // append 回空代表下一頁不存在，頁碼回到目前已持有資料的最後一頁。
                        currentPage = max(1, currentPage - 1)
                        listQuery.setPage(currentPage, size: pageSize)
                        return
                    }
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

    private func applyFilterAndReload(_ filter: AnimalListFilter) {
        currentFilter = filter
        canLoadMore = true
        currentPage = 1
        listQuery.applyFilter(currentFilter)
        listQuery.setPage(currentPage, size: pageSize)
        getPetData(updateType: .reloadList)
    }
    
    // MARK: - TodayPetItem 相關
    // 將 Data 轉換成 View Model
    private func makeTodayPetItemViewModel(for item: PetData) -> TodayPetItemViewModel {
        TodayPetItemViewModel(
            id: item.animalId,
            imageURL: URL(string: item.albumFile),
            areaName: item.animalAreaPkid.areaName(),
            kind: item.animalKind,
            imageLoader: imageLoader
        )
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
        // 今日更新與主要列表都能點進詳細頁，所以兩邊資料都要找
        return (todayPets + pets).first(where: { $0.animalId == id })
    }
}
