//
//  UILabel + Extensions .swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/14.
//

import UIKit

extension UILabel {
    func setUnderline(_ text: String, color: UIColor? = nil) {
        var attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        if let color = color {
            attributes[.underlineColor] = color
        }
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
