//
//  WebService.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/17.
//

import Foundation
import Combine

final class WebService {
    
    enum WebServiceError: Error {
        /// 網路層錯誤
        case transportError(URLError)
        /// 無效的 response
        case invalidResponse
        /// 其他 http 錯誤
        case httpError(statusCode: Int)
        /// decode 失敗
        case decodeError(Error)
        /// 其他的 Error
        case unknown(Error)
    }
    
    /// 引用依賴注入，為了方便測試
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder.apiDefault) {
        self.session = session
        self.decoder = decoder
    }
    
    /// 發送 Request 並且 decode data
    func request<T: Decodable>(_ request: URLRequest) ->AnyPublisher<T, WebServiceError> {
        
        return session.dataTaskPublisher(for: request)
        /// 轉換網路層錯誤
            .mapError { WebServiceError.transportError($0) }
        /// 檢查 HTTP Status Code 200...299 區間為成功
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw WebServiceError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw WebServiceError.httpError(statusCode: httpResponse.statusCode)
                }
                return output.data
            }
        /// 處理 data 有可能是 Empty 的情況，需要 decode 正常
            .map { data -> Data in
                if T.self is EmptyDecodable.Type, data.isEmpty {
                    return Data("{}".utf8)
                }
                return data
            }
        /// decode Data
            .decode(type: T.self, decoder: decoder)
        /// 轉換 Decode Error 為 WebServiceError ，其他已轉換好的直接扔出
            .mapError { error in
                if let wse = error as? WebServiceError { return wse }
                if error is DecodingError { return .decodeError(error) }
                /// 其他的 error
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - 為了舊畫面，先留著
extension WebService {
    /// 建立一個 Request
    private func buildRequest(
        type: HTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        httpBody: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        /// 加入與覆蓋預設 Header
        request.httpBody = httpBody
        return request
    }
    
    static func urlSessionRequest(
        type: HTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        httpBody: Data? = nil,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        
        let service = WebService()
        let request = service.buildRequest(type: type, url: url, headers: headers, httpBody: httpBody)
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}

