//
//  JSONDecoder.swift
//  StrayAnimals
//
//  Created by 小八 on 2026/2/1.
//

import Foundation

/// API 用 DateFormatter Pool（避免重複建立）
enum APIDateFormatterPool {
    /// 共用 Formatter 陣列（thread-safe）
    static let shared: [DateFormatter] = {
        
        let formats = [
            "yyyy/MM/dd",
            "yyyy-MM-dd",
            "yyyy/MM/dd HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            // ISO 8601
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
        
        return formats.map { format in
            let formatter = DateFormatter()
            /// 公曆
            formatter.calendar = Calendar(identifier: .gregorian)
            /// en_US_POSIX 忽略用戶地區設置
            formatter.locale = Locale(identifier: "en_US_POSIX")
            /// API 回傳為台灣時間
            formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
            
            formatter.dateFormat = format
            return formatter
        }
    }()
}

extension JSONDecoder {
    
    /// 全專案 API 預設 Decoder
    static var apiDefault: JSONDecoder {
        let decoder = JSONDecoder()
        
        /// snake_case -> camelCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        /// 多格式日期處理
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            
            /// 先嘗試 Unix Timestamp（秒）
            if let timestamp = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timestamp)
            }
            
            /// 再嘗試字串格式
            let string = try container.decode(String.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            /// 先處理空字串
            if string.isEmpty {
                /// 給予最小的日期
                return Date.distantPast
            }
            
            for formatter in APIDateFormatterPool.shared {
                if let date = formatter.date(from: string) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "❌ Unsupported date format: \(string)"
            )
        }
        
        return decoder
        
    }
}
