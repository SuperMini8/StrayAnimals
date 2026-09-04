//
//  TodayPetItemViewModel.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/7/29.
//

import Foundation
import Combine
import UIKit

final class TodayPetItemViewModel: Hashable {
    // Animal Data
    let id: Int
    let imageURL: URL?
    // 今日更新 Cell 底部顯示的地區名稱
    let areaName: String
    // 沒有照片時，用動物種類的預設圖當 fallback
    let kindImage: UIImage?
    
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var isImageLoading: Bool = false
    
    private let imageLoader: ImageLoading
    private var cancellables = Set<AnyCancellable>()
    // 避免 Cell 重新 configure 時重複下載同一張圖片
    private var hasStartedLoading: Bool = false
    
    init(id: Int,
         imageURL: URL?,
         areaName: String,
         kind: AnimalKind,
         imageLoader: ImageLoading) {
        self.id = id
        self.imageURL = imageURL
        self.areaName = areaName
        self.kindImage = kind.defaultImage()
        self.imageLoader = imageLoader
    }
    
    // MARK: - Hashable Class Need these two func
    static func == (lhs: TodayPetItemViewModel, rhs: TodayPetItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Image Download
    /// 下載圖片
    func loadImageIfNeeded(imageSize: ImageSizeType, imageScale: CGFloat) {
        // 已經開始下載過就不重複發 request
        guard !hasStartedLoading else { return }
        hasStartedLoading = true
        isImageLoading = true
        
        // 使用 imageKit 載處理過後的圖
        imageLoader.loadFromImageKit(from: imageURL, imageSizeType: imageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
                self?.isImageLoading = false
                if image == nil {
                    // 下載失敗時允許下次重試
                    self?.hasStartedLoading = false
                }
            }
            .store(in: &cancellables)
    }
}
