//
//  BadgeLabel.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/16.
//

import UIKit

final class BadgeLabel: UILabel {
    
    // 設定內距
    var edgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    
    init(
        frame: CGRect = .zero,
        text: String = "",
        font: UIFont = FontGroup.font(.regular, .small),
        backgroundColor: UIColor = .clear,
        textColor: UIColor = .label,
        textAlignment: NSTextAlignment = .center
        
    ) {
        super.init(frame: frame)
        
        setupLabel(
            text: text,
            font: font,
            backgroundColor: backgroundColor,
            textColor: textColor,
            textAlignment: textAlignment
        )
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel(
            text: "",
            font: FontGroup.font(.medium, .small),
            backgroundColor: .clear,
            textColor: .clear,
            textAlignment: .center
        )
    }
    
    // 繪製文字時加入內距
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: edgeInsets)
        super.drawText(in: insetRect)
    }
    
    // 告知 Layout Engine 加上內距後的尺寸
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += (edgeInsets.left + edgeInsets.right)
        size.height += (edgeInsets.top + edgeInsets.bottom)
        return size
    }
    
    // 先扣掉 padding 算文字大小，再把 padding 加回去，回傳整個 label 應該有的大小。
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let insetSize = CGSize(
            width: size.width - edgeInsets.left - edgeInsets.right,
            height: size.height - edgeInsets.top - edgeInsets.bottom
        )
        let fitted = super.sizeThatFits(insetSize)
        return CGSize(
            width: fitted.width + edgeInsets.left + edgeInsets.right,
            height: fitted.height + edgeInsets.top + edgeInsets.bottom
        )
    }
    
    /// 給初次 init 用
    private func setupLabel(
        text: String,
        font: UIFont,
        backgroundColor: UIColor,
        textColor: UIColor,
        textAlignment: NSTextAlignment
    ) {
        self.text = text
        self.font = font
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    /// 後續外部 update 使用
    func updateLabel(
        text: String,
        font: UIFont,
        backgroundColor: UIColor,
        textColor: UIColor,
        textAlignment: NSTextAlignment
    ) {
        self.text = text
        self.font = font
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.textAlignment = textAlignment
        
        // 重算尺寸
        invalidateIntrinsicContentSize()
        // 需要重畫
        setNeedsDisplay()
        // 告訴外層重新排列
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
    }

}
