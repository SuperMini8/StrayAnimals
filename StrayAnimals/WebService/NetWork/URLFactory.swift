//
//  URLFactory.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/30.
//
/// 雖然目前沒有測試環境，記錄一下最近研究的Code

import Foundation

struct URLFactory {
    
    private let environment: APIEnvironment
    
    /// 注入環境測試用
    init(environment: APIEnvironment) {
        self.environment = environment
    }
    
    /// 預設編譯環境
    init() {
        self.environment = EnvironmentManager.shared.currentEnvironment
    }

    func makeComponents(for endpoint: EndpointType) -> URLComponents {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.service.host(in: environment)
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        return components
    }
    
    func makeURL(for endpoint: EndpointType) -> URL? {
        return makeComponents(for: endpoint).url
    }
    
    func debugSummary(for endpoint: EndpointType) -> String {
        let components = makeComponents(for: endpoint)
        let urlString = components.url?.absoluteString ?? "<invalid url>"
        
        let queryItems = (components.queryItems ?? [])
            .map { "\($0.name)=\($0.value ?? "nil")" }
            .joined(separator: "&")
        
        let headerString = endpoint.headers
            .map { "\($0.key)=\($0.value)" }
            .sorted()
            .joined(separator: ", ")
        
        return """
            name=\(String(describing: type(of: endpoint)))
            env=\(environment)
            url=\(urlString)
            scheme=\(String(describing: components.scheme))
            host=\(String(describing: components.host))
            path=\(String(describing: components.path))
            query=\(queryItems.isEmpty ? "<none>" : queryItems)
            method=\(endpoint.method.rawValue)
            timeout=\(endpoint.timeout)
            bodyEncoding=\(endpoint.bodyEncoding)
            headers=\(headerString)
            bodyBytes=\(endpoint.body?.count ?? 0)
            """
    }
    
}
