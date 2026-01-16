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
    
    /// 引用依賴注入，為了方便測試
    private let session: URLSession
    
    /// 預設的 Header ， 也可根據需求覆蓋
    private let defaultHeaders: [String: String]
    /// 這裡注入預設的 Header
    init(session: URLSession = .shared, defaultHeaders: [String: String] = [:]) {
        self.session = session
        self.defaultHeaders = defaultHeaders
    }
    
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
    
    /// Raw data request as a Combine publisher.
    /// - Returns: A publisher emitting raw `Data` or `URLError`.
    func requestData(
        type: RequestType,
        url: URL,
        headers: [String: String] = [:],
        httpBody: Data? = nil,
        acceptableStatusCodes: Range<Int> = 200..<300
    ) -> AnyPublisher<Data, Error> {
        let request = buildRequest(type: type, url: url, headers: headers, httpBody: httpBody)
        return session.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                if let response = output.response as? HTTPURLResponse,
                   !acceptableStatusCodes.contains(response.statusCode) {
                    throw HTTPError.statusCode(response.statusCode)
                }
                return output.data
            }
            .eraseToAnyPublisher()
    }
    
    /// Decodes JSON into a Decodable model.
    /// - Parameters:
    ///   - decoder: Custom JSONDecoder (defaults to snake_case strategy friendly decoder).
    func requestDecodable<T: Decodable>(
        _ type: T.Type,
        method: RequestType,
        url: URL,
        headers: [String: String] = [:],
        httpBody: Data? = nil,
        decoder: JSONDecoder = WebService.defaultDecoder,
        acceptableStatusCodes: Range<Int> = 200..<300
    ) -> AnyPublisher<T, Error> {
        requestData(
            type: method,
            url: url,
            headers: headers,
            httpBody: httpBody,
            acceptableStatusCodes: acceptableStatusCodes
        )
        .decode(type: T.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
}

// MARK: - Helpers
extension WebService {
    enum HTTPError: LocalizedError, Equatable {
        case statusCode(Int)
        case invalidURL
        case emptyData
        
        var errorDescription: String? {
            switch self {
            case .statusCode(let code): return "Invalid status code: \(code)"
            case .invalidURL: return "Invalid URL."
            case .emptyData: return "Empty response data."
            }
        }
    }
    
    /// A sensible default JSONDecoder commonly used in apps.
    static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
// MARK: - Backward compatibility (optional)
extension WebService {
    /// If you still need a callback-based API somewhere, you can bridge to Combine and resubscribe here.
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

