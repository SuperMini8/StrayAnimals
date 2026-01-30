//
//  APIEndpoint.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/30.
//
/// 雖然目前沒有測試環境，記錄一下最近研究的Code

import Foundation

typealias HTTPHeaders = [String: String]

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum ParameterEncoding {
    case urlQuery
    case jsonBody
}

protocol EndpointType {
    var service: ServiceHost { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
    var queryItems: [URLQueryItem]? { get }
    var headers: HTTPHeaders { get }
    var body: Data? { get }
    var encoding: ParameterEncoding { get }
}

extension EndpointType {
    var queryItems: [URLQueryItem]? { nil }
    var headers: HTTPHeaders { [:] }
    var body: Data? { nil }
    var encoding: ParameterEncoding { .urlQuery } // 預設 GET 行為
}

enum APIEndpoint: EndpointType {
    
    case strayAnimalList(quary: StrayAnimalListQuery)
    
    var service: ServiceHost {
        switch self {
        case .strayAnimalList:
            return .gov
        }
    }
    
    var path: String {
        switch self {
        case .strayAnimalList:
            return "Service/OpenData/TransService.aspx"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .strayAnimalList:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .strayAnimalList(let quary):
            return [URLQueryItem(name: "UnitId", value: "QcbUEzN6E6DL")] + quary.toQueryItems()
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .strayAnimalList:
            return .urlQuery
        }
    }
        
}
