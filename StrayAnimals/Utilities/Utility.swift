//
//  Utility.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/12.
//

import Foundation
import UIKit

struct Utility {
    static func showAlert(title: String, message: String?, cancelTitle: String? = "Cancel", confirmlTitle: String? = "Got it", completion: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if cancelTitle != nil {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
            alertVC.addAction(cancelAction)
        }
        let confirmAction = UIAlertAction(title: confirmlTitle, style: .default, handler: completion)
        alertVC.addAction(confirmAction)
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    static func applyAttributeTextStyles(to fullText: String, blackText: String, redText: String, textColor: UIColor = .black) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let blackRange = (fullText as NSString).range(of: blackText)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: blackRange)
        
        let redRange = (fullText as NSString).range(of: redText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.MainOrange, range: redRange)
        
        return attributedString
    }
    
    static func mask(_ text: String, visiblePrefix: Int, visibleSuffix: Int) -> String {
        let chars = Array(text)
        guard chars.count > visiblePrefix + visibleSuffix else {
            return text
        }
        
        return chars.enumerated().map { index, char in
            if index < visiblePrefix || index >= chars.count - visibleSuffix {
                return String(char)
            } else {
                return "*"
            }
        }.joined()
    }

}
