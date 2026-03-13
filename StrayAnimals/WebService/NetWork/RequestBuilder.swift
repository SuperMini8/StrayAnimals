//
//  RequestBuilder.swift
//  StrayAnimals
//
//  Created by 小八 on 2026/1/31.
//

import Foundation

enum RequestBuilderError: Error {
    case invalidURL(String)
}

struct RequestBuilder {
    let urlFactory: URLFactory
    
    func build(_ endpoint: any EndpointType) throws -> URLRequest {
        guard let url = urlFactory.makeURL(for: endpoint) else {
            if EnvironmentManager.shared.isDevelopment {
                throw RequestBuilderError.invalidURL("⚠️ URL make error:\n\(urlFactory.debugSummary(for: endpoint))")
            } else {
                throw RequestBuilderError.invalidURL("⚠️ URL make error")
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = endpoint.timeout
        request.httpBody = endpoint.body
        /// 先給予 Content-Type 預設值
        if endpoint.body != nil, let bodyEncodingType = endpoint.bodyEncoding.contentType {
            request.setValue(bodyEncodingType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        /// 若 header 有 Content-Type 則以 endpoint 為主
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
                
        return request
        
    }
}
