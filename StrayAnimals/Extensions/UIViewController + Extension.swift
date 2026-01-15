//
//  UIViewController + Extension.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/7/30.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String? = "",
                   message: String?,
                   buttonTitle: String,
                   buttonStyle: UIAlertAction.Style = .default,
                   buttonAction:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: buttonTitle, style: buttonStyle, handler: buttonAction)
        alert.addAction(button)
        present(alert, animated: true)
    }
    
}
