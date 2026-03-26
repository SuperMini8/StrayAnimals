//
//  UIScreen.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/26.
//

import UIKit

extension UIScreen {
    // iOS 26 後 UIScreen.main 被標記棄用，這是抓不到 window?.windowScene?.screen 的 default scale
    /// 抓不到 current screen 時的預設 scale
    static var currentFallbackScale: CGFloat {
        2
    }
}
