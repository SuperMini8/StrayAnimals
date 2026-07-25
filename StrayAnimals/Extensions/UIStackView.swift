//
//  UIStackView.swift
//  StrayAnimals
//
//  Created by 小八 on 2026/7/25.
//

import UIKit

extension UIStackView {
    /// 移除所有 ArrangedSubview
    func removeAllArrangedSubview() {
        self.arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    /// 移除特定的 ArrangedSubview
    func removeArrangedSubviewCompletely(_ view: UIView) {
        self.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}
