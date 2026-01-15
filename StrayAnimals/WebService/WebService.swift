//
//  WebService.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/17.
//

import Foundation

class WebService {
    
    enum RequestType: String {
        case get   = "GET"
        case post  = "POST"
    }
    
    static func urlSessionRequest(type: RequestType,
                                  url: URL,
                                  headers: [String: String] = [:],
                                  httpBody: Data? = nil,
                                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
}
