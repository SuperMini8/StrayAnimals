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
    
    init() {
        self.environment = EnvironmentManager.shared.currentEnvironment
    }
    
    func makeURL(for endpoint: EndpointType) -> URL? {
        var components = URLComponents()
        components.scheme = environment.scheme
        components.host = endpoint.service.host(in: environment)
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        return components.url
    }
    
}
