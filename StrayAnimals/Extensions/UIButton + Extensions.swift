//
//  UIButton + Extensions.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/14.
//

import UIKit

extension UIButton {
    func setUnderline(_ text: String, color: UIColor? = nil, font: UIFont? = nil, for state: UIControl.State = .normal) {
        var attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        if let color = color {
            attributes[.underlineColor] = color
            attributes[.foregroundColor] = color
        }
        
        if let font = font {
            attributes[.font] = font
        }
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        self.setAttributedTitle(attributedString, for: state)
    }
}
