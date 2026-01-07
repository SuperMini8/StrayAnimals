//
//  UILabel + Extensions .swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/14.
//

import UIKit

extension UILabel {
    
    enum ImageArrangementType {
        case left
        case right
    }
    
    func setUnderline(_ text: String, color: UIColor? = nil) {
        var attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        if let color = color {
            attributes[.underlineColor] = color
        }
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func setTextAndImage(text: String, font: UIFont, imageName: String, imageArrangement: ImageArrangementType) {
        // 處理圖片
        let attText = NSMutableAttributedString()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: imageName)
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: font.pointSize, height: font.pointSize)
        // 處理文字
        let text = NSAttributedString(string: text)
        // 照順序加入
        switch imageArrangement {
        case .left:
            attText.append(NSAttributedString(attachment: imageAttachment))
            attText.append(text)
        case .right:
            attText.append(text)
            attText.append(NSAttributedString(attachment: imageAttachment))
        }
        // 處理 Font
        let range = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: font, range: range)
        // 設定 attributedText
        self.attributedText = attText
    }
}
