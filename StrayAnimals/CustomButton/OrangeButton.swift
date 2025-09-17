//
//  OrangeButton.swift
//  MVVM_Combine_Demo
//
//  Created by Elma YEH 葉品妤 on 2025/7/29.
//

import UIKit

class OrangeButton: UIButton {
    
    enum OrangeButtonStyle {
        case fillOrange
        case borderOrange
    }
    
    private var normalImageName: String = ""
    private var disableImageName: String = ""
    
    init(title: String,
         normalImageName: String = "",
         disableImageName: String = "",
         style: OrangeButtonStyle) {
        super.init(frame: .zero)
        setupUI(title: title, normalImageName: normalImageName, disableImageName: disableImageName, style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("OrangeButton init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String,
                         normalImageName: String = "",
                         disableImageName: String = "",
                         style: OrangeButtonStyle) {
        var configuration = UIButton.Configuration.filled()
        configuration.background.cornerRadius = 12
        configuration.cornerStyle = .fixed
        
        configuration.imagePadding = 8
        self.normalImageName = normalImageName
        self.disableImageName = disableImageName
        
        self.configuration = configuration
        updateTitle(title: title)
        
        configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            switch style {
            case .fillOrange:
                button.configuration = self.setupFillOrangeUI(button: button)
            case .borderOrange:
                button.configuration = self.setupBorderOrangeUI(button: button)
            }
        }
    }
    
    func updateTitle(title: String) {
        let attributes = AttributeContainer([.font: FontBook.font(.bold, fontSize: .size(17))])
        let attributeTitle = AttributedString(title, attributes: attributes)
        configuration?.attributedTitle = attributeTitle
    }
    
    private func setupFillOrangeUI(button: UIButton) -> UIButton.Configuration? {
        var config = button.configuration
        
        config?.background.strokeWidth = 0
        
        switch button.state {
        case .disabled:
            config?.background.strokeColor = .clear
            config?.baseForegroundColor = .Gray400
            config?.background.backgroundColor = .Gray200
            if disableImageName != "" {
                config?.image = UIImage(named: disableImageName)
            }
        case .highlighted:
            config?.background.strokeColor = .clear
            config?.baseForegroundColor = .white
            config?.background.backgroundColor = .DeepOrange
        default:
            config?.background.strokeColor = .clear
            config?.baseForegroundColor = .white
            config?.background.backgroundColor = .MainOrange
            if normalImageName != "" {
                config?.image = UIImage(named: normalImageName)
            }
        }
        
        return config
    }
    
    private func setupBorderOrangeUI(button: UIButton) -> UIButton.Configuration? {
        var config = button.configuration
        config?.background.strokeWidth = 1
        
        switch button.state {
        case .disabled:
            config?.background.strokeColor = .Gray200
            config?.baseForegroundColor = .Gray400
            config?.background.backgroundColor = .white
            if disableImageName != "" {
                config?.image = UIImage(named: disableImageName)
            }
        case .highlighted:
            config?.background.strokeColor = .MainOrange
            config?.baseForegroundColor = .MainOrange
            config?.background.backgroundColor = .LightOrange
        default:
            config?.background.strokeColor = .MainOrange
            config?.baseForegroundColor = .MainOrange
            config?.background.backgroundColor = .white
            if normalImageName != "" {
                config?.image = UIImage(named: normalImageName)
            }
        }
        
        return config
    }
    
}
