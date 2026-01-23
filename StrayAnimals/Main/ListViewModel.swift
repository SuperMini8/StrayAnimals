//
//  ListViewModel.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import Combine

class ListViewModel {
    
    var pets: [PetData] = []
    
    var reloadList: (() -> Void)?
    
    private let petWebService = PetWebService()
    private var cancellables = Set<AnyCancellable>()
    
    func getPetData(top: Int, skip: Int) {
        petWebService.topAmount = top
        petWebService.skipAmount = skip
        petWebService.searchPetDataPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] data in
                self?.pets = data
                self?.reloadList?()
            })
            .store(in: &cancellables)
    }
}
