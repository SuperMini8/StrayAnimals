//
//  ServiceHost.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/30.
//
/// 雖然目前沒有測試環境，記錄一下最近研究的Code

import Foundation

enum ServiceHost {
    
    case gov
    case google
    
    func host(in env: APIEnvironment) -> String {
        switch env {
        /// 並沒有測試 domain，此架構練習用
        case .dev,
             .production:
            switch self {
            case .gov:
                return "data.moa.gov.tw"
            case .google:
                return "www.google.com"
            }
        }
    }
    
}
