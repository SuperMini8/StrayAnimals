//
//  FontBook.swift
//  CrossPay
//
//  Created by Lily TSAI 蔡佳玲 on 2025/7/29.
//

import Foundation

import UIKit

struct FontBook {

    enum FontType {
        case bold
        case medium
        case regular
        case sfproRegular
        case sfproMedium
        case sfproBold
    }

    /**
     ```
     case large
     case normal
     case small
     case navigation
     case size(CGFloat)
     ```
     */
    enum FontSize {
        /// size 34
        case large

        /// size 16
        case normal

        /// size 14
        case small

        /// size 18
        case navigation

        /// custom your size
        case size(CGFloat)

        func value() -> CGFloat {
            switch self {
            case .large: return 34
            case .normal: return 16
            case .small: return 14
            case .navigation: return 18
            case .size(let size): return size
            }
        }
    }

    static func font(_ fontType: FontType, fontSize: FontSize) -> UIFont {
        let size: CGFloat = fontSize.value()
        switch fontType {
        case .bold:
            return UIFont(name: "PingFangTC-Semibold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        case .medium:
            return UIFont(name: "PingFangTC-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .regular:
            return UIFont(name: "PingFangTC-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
        case .sfproRegular:
            return UIFont.systemFont(ofSize: size, weight: .regular)
        case .sfproMedium:
            return UIFont.systemFont(ofSize: size, weight: .medium)
        case .sfproBold:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
    }
}
