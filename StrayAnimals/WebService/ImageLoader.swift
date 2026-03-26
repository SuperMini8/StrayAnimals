//
//  ImageLoader.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/13.
//

import Foundation
import Combine
import UIKit

protocol ImageLoading {
    func loadImage(from url: URL?, targetSize: CGSize, scale: CGFloat) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoader: ImageLoading {
    static let shared = ImageLoader(session: URLSession.shared)
    
    private let session: URLSession
    private let cache: NSCache<NSString, UIImage>
    
    init(session: URLSession, cache: NSCache<NSString, UIImage> = NSCache()) {
        self.session = session
        self.cache = cache
    }
    
    private var inFlightPublishers: [String: AnyPublisher<UIImage?, Never>] = [:]
    private let lock = NSLock()
    
    func loadImage(from url: URL?, targetSize: CGSize, scale: CGFloat) -> AnyPublisher<UIImage?, Never> {
        // 先抓取 url
        guard let url else {
            return Just(nil).eraseToAnyPublisher()
        }
        // 再來尋找有沒有 cache 的
        let cacheKey = makeCacheKey(url: url, targetSize: targetSize, scale: scale)
        if let cached = cache.object(forKey: cacheKey as NSString) {
            return Just(cached).eraseToAnyPublisher()
        }
        
        // Request 前先 lock 避免多次 request
        lock.lock()
        // 避免同一張圖短時間重複打 API，檢查正載下載的 url
        if let existing = inFlightPublishers[cacheKey] {
            lock.unlock()
            return existing
        }
        
        let publisher = session.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap{ [weak self] data, response -> UIImage? in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WebServiceError.invalidResponse
                }
                // 判斷 statusCode 200...299 才是正常回應
                guard 200...299 ~= httpResponse.statusCode else {
                    throw WebServiceError.httpError(statusCode: httpResponse.statusCode)
                }
                return self?.downsampleImage(data: data, to: targetSize, scale: scale)
            }
            // 有 error 就丟一個 nil，對於 error 不做處理額外處理
            .replaceError(with: nil)
            // 對於分別完成的狀態做後續處理
            .handleEvents(
                // 收到 Output 時，把 image cache 住
                receiveOutput: { [weak self] image in
                    guard let image else { return }
                    self?.cache.setObject(image, forKey: cacheKey as NSString)
                },
                // 當下載流程結束時，清除正載下載的 cacheKey
                receiveCompletion: { [weak self] _ in
                    self?.removeInFlight(for: cacheKey)
                },
                // 當下載流程被取消時，清除正載下載的 cacheKey
                receiveCancel: { [weak self] in
                    self?.removeInFlight(for: cacheKey)
                }
            )
            // 讓每一個訂閱此 publisher 的共用同一個 request
            .share()
            // 讓回傳型別變得統一，每有一個 operator 都會加長型別
            .eraseToAnyPublisher()
        
        // 儲存正在下載的任務
        inFlightPublishers[cacheKey] = publisher
        // 同個 func 內，有 lock 就一定要 unlock
        lock.unlock()
        
        return publisher
    }
    /// 移除已經完成下載的 url
    private func removeInFlight(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        inFlightPublishers.removeValue(forKey: key)
    }
    /// 用 url + 指定大小 + 縮放比例 當 key
    private func makeCacheKey(url: URL, targetSize: CGSize, scale: CGFloat) -> String {
        let width = Int(targetSize.width.rounded())     // rounded 進行四捨五入
        let height = Int(targetSize.height.rounded())
        let scaleInt = Int(scale.rounded())
        return "\(url)_W:\(width)_H:\(height)_S:\(scaleInt)"
    }
    /// 將 Data 變成指定大小的圖
    private func downsampleImage(data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        // 這張圖需要的 Pixels
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // 建立圖片資料的讀取器
        let options: CFDictionary = [
            // 先不要在這一步就把整張圖片快取 / 解碼進記憶體
            kCGImageSourceShouldCache: false
        ] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, options) else { return nil }
        
        // 生產縮圖的規則
        let downsampleOptions: CFDictionary = [
            // 產生縮圖
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            // 產生縮圖時，已經解碼完成，避免畫面卡頓
            kCGImageSourceShouldCacheImmediately: true,
            // 處理圖片本身的方向
            kCGImageSourceCreateThumbnailWithTransform: true,
            // 產生一張不超過 maxDimensionInPixels 的 Thumbnail(縮圖)
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        // 產出 CGImage 的縮圖
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
}
