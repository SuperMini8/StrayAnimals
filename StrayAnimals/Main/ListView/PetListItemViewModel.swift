//
//  PetListItemViewModel.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/24.
//

import Foundation
import Combine
import UIKit

final class PetListItemViewModel: Hashable {
    // animalId for Hashable
    let id: Int
    let imageURL: URL?
    let kind: AnimalKind
    let variety: String
    let sex: AnimalSex
    let status: AnimalStatus
    let age: String
    let place: String
    
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var isImageLoading: Bool = false
    
    private let imageLoader: ImageLoading
    private var cancellables = Set<AnyCancellable>()
    private var hasStartedLoading: Bool = false
    
    init(
        id: Int,
        imageURL: URL?,
        kind: AnimalKind,
        variety: String,
        sex: AnimalSex,
        status: AnimalStatus,
        age: AnimalAge,
        place: String,
        imageLoader: ImageLoading
    ) {
        self.id = id
        self.imageURL = imageURL
        self.kind = kind
        self.variety = "品種：" + variety
        self.sex = sex
        self.status = status
        self.age = "年紀：" + age.AgeText()
        self.place = place
        self.imageLoader = imageLoader
    }
    
    // MARK: - Hashable Class Need these two func
    static func == (lhs: PetListItemViewModel, rhs: PetListItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Image Download
    /// 下載圖片
    func loadImageIfNeeded(imageSize: ImageSizeType, imageScale: CGFloat) {
        guard !hasStartedLoading else { return }
        hasStartedLoading = true
        isImageLoading = true
        
        /* 載原圖
        imageLoader.loadImage(from: imageURL, targetSize: imageSize, scale: imageScale)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
                self?.isImageLoading = false
            }
            .store(in: &cancellables)
        */
        // 改使用 imageKit 載處理過後的圖
        imageLoader.loadFromImageKit(from: imageURL, imageSizeType: imageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
                self?.isImageLoading = false
            }
            .store(in: &cancellables)
    }
}
