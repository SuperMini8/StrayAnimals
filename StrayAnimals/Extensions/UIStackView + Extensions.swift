//
//  UIStackView + Extensions.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/12.
//

import UIKit

extension UIStackView {
    func addArrangeSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }

    func removeArrangeSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}

