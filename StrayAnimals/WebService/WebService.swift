//
//  WebService.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/17.
//

import Foundation
import Combine

final class WebService {
    
    enum RequestType: String {
        case get   = "GET"
        case post  = "POST"
        case put   = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    enum WebServiceError: Error {
        /// String 轉換成 URL 失敗
        case invalidURL(String)
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
    /// 預設的 Header ， 也可根據需求覆蓋
    private let defaultHeaders: [String: String]
    
    /// 這裡注入預設的 Header
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder(), defaultHeaders: [String: String] = [:]) {
        self.session = session
        self.decoder = decoder
        self.defaultHeaders = defaultHeaders
    }
    
    /// 建立 Request
    private func createRequest(method: RequestType,
                               urlString: String,
                               headers: [String: String] = [:],
                               body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        /// 加入與覆蓋預設的 Header
        let merged = defaultHeaders.merging(headers) { _, new in new }
        request.allHTTPHeaderFields = merged
        request.httpBody = body
        return request
    }
    
    /// 發送 Request 並且 decode data
    func request<T: Decodable>(method: RequestType,
                 urlString: String,
                 headers: [String : String] = [:],
                               body: Data? = nil) ->AnyPublisher<T, WebServiceError> {
        guard let request = createRequest(method: method, urlString: urlString, headers: headers, body: body) else {
            return Fail(error: WebServiceError.invalidURL("\(urlString) init URL is invalid")).eraseToAnyPublisher()
        }
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
                if let wse = error as? WebServiceError {
                    return wse
                }
                if error is DecodingError {
                    return .decodeError(error)
                }
                /// 其他的 error
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Backward compatibility (optional)
extension WebService {
    /// If you still need a callback-based API somewhere, you can bridge to Combine and resubscribe here.
    /// 建立一個 Request
    private func buildRequest(
        type: RequestType,
        url: URL,
        headers: [String: String] = [:],
        httpBody: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        /// 加入與覆蓋預設 Header
        var merged = defaultHeaders
        headers.forEach { merged[$0.key] = $0.value }
        request.allHTTPHeaderFields = merged
        request.httpBody = httpBody
        return request
    }
    
    static func urlSessionRequest(
        type: RequestType,
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

