//
//  UIButton.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/5/27.
//

import UIKit

enum ActionButtonStyle {
    case outlined(title: String?, image: UIImage?)
    case filled(title: String?, image: UIImage?)
}

extension UIButton {
    
    func setConfiguration(style: ActionButtonStyle) {
        var config = UIButton.Configuration.filled()
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.cornerStyle = .large
        
        switch style {
        case .outlined(let title, let image):
            if let title {
                config.attributedTitle = AttributedString(
                    title,
                    attributes: AttributeContainer([
                        .font: FontGroup.font(.medium, .medium)
                    ])
                )
            }
            if let image {
                config.image = image
            }
            config.baseForegroundColor = .label
            config.background.backgroundColor = .white
            config.background.strokeColor = .label
            config.background.strokeWidth = 1
            
        case .filled(let title, let image):
            if let title {
                config.attributedTitle = AttributedString(
                    title,
                    attributes: AttributeContainer([
                        .font: FontGroup.font(.medium, .medium)
                    ])
                )
            }
            if image != nil {
                config.image = image
            }
            config.baseForegroundColor = .label
            config.background.backgroundColor = UIColor.navigationBar
        }
        self.configuration = config
    }
    
}
