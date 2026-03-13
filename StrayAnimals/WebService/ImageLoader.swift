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
    func loadImage(from url: URL?) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoader: ImageLoading {
    static let shared = ImageLoader()
    private init() {}
    
    private var cache = NSCache<NSURL, UIImage>()
    private var inFlightPublishers: [URL: AnyPublisher<UIImage?, Never>] = [:]
    private let lock = NSLock()
    
    func loadImage(from url: URL?) -> AnyPublisher<UIImage?, Never> {
        // 先抓取 url
        guard let url else {
            return Just(nil).eraseToAnyPublisher()
        }
        // 再來尋找有沒有 cache 的
        if let cached = cache.object(forKey: url as NSURL) {
            return Just(cached).eraseToAnyPublisher()
        }
        
        // Request 前先 lock 避免多次 request
        lock.lock()
        // 避免同一張圖短時間重複打 API，檢查正載下載的 url
        if let existing = inFlightPublishers[url] {
            lock.unlock()
            return existing
        }
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            //  只取 data，「\.」為某個物件的 data 屬性。
            .map(\.data)
            // 先將 data 轉型成 UIImage
            .map { UIImage(data: $0) }
            // 有 error 就丟一個 nil，對於 error 不做處理額外處理
            .replaceError(with: nil)
            // 對於分別完成的狀態做後續處理
            .handleEvents(
                // 收到 Output 時，把 image cache 住
                receiveOutput: { [weak self] image in
                    guard let image else { return }
                    self?.cache.setObject(image, forKey: url as NSURL)
                },
                // 當下載流程結束時，清除正載下載的 url
                receiveCompletion: { [weak self] _ in
                    self?.removeInFlight(for: url)
                },
                // 當下載流程被取消時，清除正載下載的 url
                receiveCancel: { [weak self] in
                    self?.removeInFlight(for: url)
                }
            )
            // 讓每一個訂閱此 publisher 的共用同一個 request
            .share()
            // 讓回傳型別變得統一，每有一個 operator 都會加長型別
            .eraseToAnyPublisher()
        
        // 儲存正在下載的任務
        inFlightPublishers[url] = publisher
        // 同個 func 內，有 lock 就一定要 unlock
        lock.unlock()
        
        return publisher
    }
    /// 移除已經完成下載的 url
    private func removeInFlight(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        inFlightPublishers.removeValue(forKey: url)
    }
    
}
