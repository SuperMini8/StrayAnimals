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
    case none
    case json
    case formURLEncoded
    
    var contentType: ContentType? {
        switch self {
        case .none:
            return nil
        case .json:
            return .json
        case .formURLEncoded:
            return .formURLEncoded
        }
    }
}

enum ContentType: String {
    /// 傳送 json 格式 body
    case json = "application/json"
    /// 傳送 URLEncoding 格式 body
    case formURLEncoded = "application/x-www-form-urlencoded; charset=utf-8"
}

protocol EndpointType {
    var scheme: String { get }
    var service: ServiceHost { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
    var queryItems: [URLQueryItem]? { get }
    var headers: HTTPHeaders { get }
    var body: Data? { get }
    var bodyEncoding: ParameterEncoding { get }
    var timeout: TimeInterval { get }
}

extension EndpointType {
    var scheme: String { "https" }
    var queryItems: [URLQueryItem]? { nil }
    var headers: HTTPHeaders { [:] }
    var body: Data? { nil }
    var bodyEncoding: ParameterEncoding { .none }
    var timeout: TimeInterval { 30 } // 預設 30 秒 Timeout
}

enum APIEndpoint: EndpointType {
    
    case strayAnimalList(query: StrayAnimalListQuery)
    
    var service: ServiceHost {
        switch self {
        case .strayAnimalList:
            return .gov
        }
    }
    
    var path: String {
        switch self {
        case .strayAnimalList:
            return "/Service/OpenData/TransService.aspx"
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
        case .strayAnimalList(let query):
            return [URLQueryItem(name: "UnitId", value: "QcbUEzN6E6DL")] + query.toQueryItems()
        }
    }
    
    var bodyEncoding: ParameterEncoding {
        switch self {
        case .strayAnimalList:
            return .none
        }
    }
        
}
