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
    
    func host(in env: APIEnvironment) -> String {
        switch self {
        case .gov:
            switch env {
            case .dev,
                 .production:
                return "data.moa.gov.tw"
            }
        }
    }
    
}
