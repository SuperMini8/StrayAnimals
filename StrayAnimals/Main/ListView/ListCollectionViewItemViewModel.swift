//
//  ListCollectionViewItemViewModel.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/24.
//

import Foundation
import Combine
import UIKit

final class ListCollectionViewItemViewModel {
    
    let imageURL: URL?
    let kind: AnimalKind
    let sex: AnimalSex
    let status: AnimalStatus
    let age: AnimalAge
    let place: String
    
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var isImageLoading: Bool = false
    
    private let imageLoader: ImageLoading
    private var cancellables = Set<AnyCancellable>()
    private var hasStartedLoading: Bool = false
    
    init(
        imageURL: URL?,
        kind: AnimalKind,
        sex: AnimalSex,
        status: AnimalStatus,
        age: AnimalAge,
        place: String,
        imageLoader: ImageLoading
    ) {
        self.imageURL = imageURL
        self.kind = kind
        self.sex = sex
        self.status = status
        self.age = age
        self.place = place
        self.imageLoader = imageLoader
    }
    /// 下載圖片
    func loadImageIfNeeded(imageSize: CGSize, imageScale: CGFloat) {
        guard !hasStartedLoading else { return }
        hasStartedLoading = true
        isImageLoading = true
        
        imageLoader.loadImage(from: imageURL, targetSize: imageSize, scale: imageScale)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
                self?.isImageLoading = false
            }
            .store(in: &cancellables)
    }
}
