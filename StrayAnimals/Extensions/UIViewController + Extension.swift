//
//  UIViewController + Extension.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/7/30.
//

import UIKit

extension UIViewController {
    
    func presentFullScreen(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if self.presentedViewController == nil { // MARK: - Fix present modally an active controller,
            //MARK: - Remove run in main thread code because of present modally issue
            viewControllerToPresent.modalPresentationStyle = .fullScreen
            self.present(viewControllerToPresent, animated: animated, completion: completion)
        } else {
            self.presentedViewController?.dismiss(animated: false) {
                self.presentFullScreen(viewControllerToPresent)
            }
        }
    }
    
    func setNavBackStyle(title: String? = nil, titleColor: UIColor = .black) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.setImage(UIImage(named: "icon_nav_arrow_left"), for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = FontBook.font(.bold, fontSize: .size(17))
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(leaveViewController), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = backBarItem
    }

    func setNavCloseButton(onLeft: Bool = true, action: Selector) {
        let closeBarItem = UIBarButtonItem(image: UIImage(named: "icon_nav_close"),
                                           style: .plain,
                                           target: self, action: action)

        if onLeft {
            navigationItem.leftBarButtonItem = closeBarItem
        } else {
            navigationItem.rightBarButtonItem = closeBarItem
        }
        navigationController?.navigationBar.tintColor = .black
    }
    
    func setNormalTitleStyle(title: String?, textColor: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.Gray100) {
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = false

        let attributes: [NSAttributedString.Key: Any] = [.font: FontBook.font(.bold, fontSize: .size(17)),
                                                         .foregroundColor: textColor]

        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = backgroundColor
        barAppearance.titleTextAttributes = attributes
        barAppearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = barAppearance
        navigationController?.navigationBar.compactAppearance = barAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
    }
    
    @objc private func leaveViewController() {
        leaveViewController(completion: nil)
    }

    @objc func leaveViewController(animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        if let viewcontrollers = navigationController?.viewControllers, viewcontrollers.count > 1 {
            if viewcontrollers[viewcontrollers.count - 1] == self {
                navigationController?.setNavigationBarHidden(false, animated: false)
                _ = navigationController?.popViewController(animated: true)
                completion?()
            }
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }
    
    func setupRightBarButton(image: UIImage?, action: Selector = #selector(popToRootVC)) {
        let barButtonItem = UIBarButtonItem(image: image,
                                            style: .plain,
                                            target: self, action: action)
        navigationItem.rightBarButtonItem = barButtonItem
        navigationController?.navigationBar.tintColor = .Gray800
    }
    
    @objc func popToRootVC() {
        navigationController?.popToRootViewController(animated: true)
    }
    
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
