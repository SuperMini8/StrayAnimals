//
//  EnvironmentManager.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/30.
//
/// 雖然目前沒有測試環境，記錄一下最近研究的Code

import Foundation
/// 環境管理
final class EnvironmentManager {
    static let shared = EnvironmentManager()
    
    private init() {}
    
    private let envString: String = {
            Bundle.main.infoDictionary?["APP_ENV"] as? String ?? "prod"
        }()
    
    var currentEnvironment: APIEnvironment {
        switch envString {
        case "dev": return .dev
        case "prod": return .production
        default: return .production
        }
    }
    
    /// 是否為開發環境
    var isDevelopment: Bool {
        currentEnvironment == .dev
    }
    
    /// 是否為生產環境
    var isProduction: Bool {
        currentEnvironment == .production
    }
    
}
