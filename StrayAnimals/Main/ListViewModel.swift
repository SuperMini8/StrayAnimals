//
//  ListViewModel.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import Combine

class ListViewModel {
    
    // @Published 收到值後，自動發送通知給訂閱者
    @Published var pets: [PetData] = []
    // 用 Set 存訂閱，避免重複的訂閱
    var cancellables = Set<AnyCancellable>()
    
    func getPetData() {
        let webservice = WebService()
        var query = StrayAnimalListQuery()
        query.setPage(1, size: 10)
        webservice.sendRequest(with: APIEndpoint.StrayAnimalList(query: query))
            // 在主執行緒
            .receive(on: DispatchQueue.main)
            // 建立訂閱
            .sink { completion in
                switch completion {
                case .finished:
                    print("Request finished.")
                case .failure(let error):
                    print("Request failed with: \(error)")
                }
                print(completion)
            } receiveValue: { [weak self] response in
                self?.pets = response
            }
            // 把訂閱存起來，避免被自動取消
            .store(in: &cancellables)
    }
}
