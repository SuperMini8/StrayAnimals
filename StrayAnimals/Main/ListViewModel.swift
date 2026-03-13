//
//  ListViewModel.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import Combine

class ListViewModel {
        
    // 用 Set 存訂閱，避免重複的訂閱
    var cancellables = Set<AnyCancellable>()
    
    // @Published 收到值後，自動產生 publisher 發送新值給訂閱者，接收者需透過 $ 存取。
    @Published var pets: [PetData] = []
    // 頁面資料數量狀態
    lazy private var listQuery: StrayAnimalListQuery = StrayAnimalListQuery(top: pageSize)
    private var currentPage: Int = 1
    private var pageSize: Int = 10
    private var canLoadMore: Bool = true
    @Published var isLoading: Bool = false
    
    // 接收 ViewController 來的事件
    let viewdidLoad = PassthroughSubject<Void, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
    
    init(startPage: Int, pageSize: Int) {
        self.currentPage = startPage
        self.pageSize = pageSize
        bind()
    }
    
    func bind() {
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
    
    func getPetData() {
        
        isLoading = true
        
        let webservice = WebService()
        webservice.sendRequest(with: APIEndpoint.StrayAnimalList(query: listQuery))
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
                self?.pets.append(contentsOf: response)
            }
            // 把訂閱存起來，避免被自動取消
            .store(in: &cancellables)
    }
    
    func loadNextPage() {
        currentPage += 1
        listQuery.setPage(currentPage, size: pageSize)
        getPetData()
    }
}
