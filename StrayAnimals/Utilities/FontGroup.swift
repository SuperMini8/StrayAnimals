//
//  FontGroup.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/11.
//

import Foundation
import UIKit

struct FontGroup {
    
    enum FontType {
        case bold
        case medium
        case regular
    }
    
    enum FontSize: CGFloat {
        /// 14
        case small = 14
        /// 18
        case medium = 18
        /// 20
        case highLight = 22
        /// 28
        case large = 28
    }
    
    static func font(_ type: FontType, _ size: FontSize) -> UIFont {
        let fontSize = size.rawValue
        switch type {
        case .bold:
            return UIFont.systemFont(ofSize: fontSize, weight: .bold)
        case .medium:
            return UIFont.systemFont(ofSize: fontSize, weight: .medium)
        case .regular:
            return UIFont.systemFont(ofSize: fontSize, weight: .regular)
        }
    }
    
    
}
