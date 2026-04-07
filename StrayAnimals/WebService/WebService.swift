//
//  WebService.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/17.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func sendRequest<E: EndpointType>(with endpoint: E) -> AnyPublisher<E.response, WebServiceError>
}

enum WebServiceError: Error {
    /// 網路層錯誤
    case transportError(URLError)
    /// 無效的 response
    case invalidResponse
    /// 其他 http 錯誤
    case httpError(statusCode: Int)
    /// 回傳內容不是 JSON
    case invalidResponseBody(String)
    /// decode 失敗
    case decodeError(Error)
    /// 其他的 Error
    case unknown(Error)
    
    /// show 給 alert 用的
    func errorMassage() -> String {
        switch self {
        case .transportError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .invalidResponseBody(let errorMessage):
            return "Invalid response body: \(errorMessage)"
        case .decodeError(let error):
            return "Decode Error: \(error)"
        case .unknown(_):
            return "Unknown Error"
        }
    }
}

final class WebService: APIClientProtocol {
    
    
    /// 引用依賴注入，為了方便測試
    private let session: URLSession
    private let requestBuilder: RequestBuilder
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared,
         requestBuilder: RequestBuilder = .init(urlFactory: .init()),
         decoder: JSONDecoder = .apiDefault) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.decoder = decoder
    }
    
    /// 發送 Request 並且 decode data
    func sendRequest<E: EndpointType>(with endpoint: E) ->AnyPublisher<E.response, WebServiceError> {
        let request: URLRequest
        do { request = try requestBuilder.build(endpoint) }
        catch { return Fail(error: .unknown(error)).eraseToAnyPublisher() }
        
        return session.dataTaskPublisher(for: request)
        /// 轉換網路層錯誤
            .mapError { WebServiceError.transportError($0) }
        /// 檢查 HTTP Status Code 200...299 區間為成功
            .tryMap { output -> Data in
                /// 轉換 response 失敗
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw WebServiceError.invalidResponse
                }
                /// 判斷 statusCode 200...299 才是正常回應
                guard 200...299 ~= httpResponse.statusCode else {
                    throw WebServiceError.httpError(statusCode: httpResponse.statusCode)
                }
                /// 檢查 Content-Type，是否為 JSON
                let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
                let likelyJSONContentType =
                    contentType.contains("application/json") ||
                    contentType.contains("text/json") ||
                    contentType.contains("text/plain") ||
                    contentType.isEmpty
                guard likelyJSONContentType else {
                    throw WebServiceError.invalidResponseBody("Content-Type is \(contentType)")
                }
                /// 檢查 body 的內容物，剔除為 HTML 的部分
                let dataString = String(data: output.data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                 if dataString.hasPrefix("<!DOCTYPE html") ||
                    dataString.hasPrefix("<html") ||
                    dataString.hasPrefix("<") {
                     throw WebServiceError.invalidResponseBody("is HTML body")
                 }
                
                return output.data
            }
        /// 處理 data 有可能是 Empty 的情況，需要 decode 正常
            .map { data -> Data in
                if E.response.self is EmptyDecodable.Type,
                   let string = String(data: data, encoding: .utf8),
                   string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    
                    return Data("{}".utf8)
                }
                return data
            }
        /// decode Data
            .decode(type: E.response.self, decoder: decoder)
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

