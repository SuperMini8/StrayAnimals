//
//  APIEnvironment.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/30.
//
/// 雖然目前沒有測試環境，記錄一下最近研究的Code

import Foundation

/// API 環境
enum APIEnvironment {
    
    case dev
    case production
    
    var scheme: String { "https" }
    
}
