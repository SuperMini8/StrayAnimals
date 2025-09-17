//
//  String + Extensions.swift
//  CrossPay
//
//  Created by Lily TSAI 蔡佳玲 on 2025/7/30.
//

import Foundation
import UIKit

extension String {
    
    func validateRegex(regex: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    func isTaiwanPhoneFormat() -> Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^09\\d{8}"
        return trimmed.validateRegex(regex: regex)
    }
    
    ///驗證字串是否只含數字與英文，字串長度並在6~12個字元之間
    func isPasswordFormat() -> Bool {
        let trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let regex = "^([a-zA-Z]+\\d+|\\d+[a-zA-Z]+)[a-zA-Z0-9]*$"
        return (trimmed.validateRegex(regex: regex) && trimmed.count >= 6 && trimmed.count <= 12)
    }
    
    func isEmailFormat() -> Bool {
        let trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"

        let regexLength = "^.{1,100}$"
        return (trimmed.validateRegex(regex: regex) && trimmed.validateRegex(regex: regexLength))
    }
    
    /// 驗證是否符合「英數混合，且不可為重複或連續字元」
    func isValidPassword() -> Bool {
        let regex = "([a-zA-Z0-9])\\1\\1+|(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz|cba|dcb|edc|fed|gfe|hgf|ihg|jih|kji|lkj|mlk|nml|onm|pon|qpo|rqp|srq|tsr|uts|vut|wvu|xwv|yxw|zyx|012|123|234|345|456|567|678|789|987|876|765|654|543|432|321|210)+"
        let check = RegularExpression(regex: regex)
        if check.count > 0{
            return false
        }
        return true
    }
    
    func RegularExpression (regex:String) -> [String]{
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            var data:[String] = Array()
            for item in matches {
                let string = (self as NSString).substring(with: item.range)
                data.append(string)
            }
            return data
        }catch {
            return []
        }
    }
}
