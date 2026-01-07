//
//  ListViewModel.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation

class ListViewModel {
    
    var pets: [PetData] = []
    
    var reloadList: (() -> Void)?
    
    func getPetData(top: Int, skip: Int) {
        let petWebService = PetWebService()
        petWebService.topAmount = top
        petWebService.skipAmount = skip
        petWebService.searchPetData { [weak self] data in
            guard let self, let data = data else { return }
            self.pets = data
            DispatchQueue.main.async { [ weak self] in
                self?.reloadList?()
            }
        }
    }
}
