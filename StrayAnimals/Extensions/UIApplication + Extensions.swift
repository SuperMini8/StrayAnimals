//
//  UIApplication + Extensions.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/12.
//

import UIKit

extension UIApplication {
    var mainKeyWindow: UIWindow? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    class func topViewController(base: UIViewController? = UIApplication.shared.mainKeyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}

