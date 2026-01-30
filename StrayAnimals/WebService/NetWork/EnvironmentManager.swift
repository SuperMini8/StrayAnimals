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
    
    var currentEnvironment: APIEnvironment {
        #if DEBUG
            return .dev
        #else
            return .production
        #endif
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
