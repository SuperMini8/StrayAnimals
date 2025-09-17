//
//  UIView + Extensions.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/7/30.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }

    func drawShadow(color: UIColor = UIColor.black.withAlphaComponent(0.1), opacity: Float = 0.8, offset: CGSize = .zero, radius: CGFloat = 5) {
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
}
