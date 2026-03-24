//
//  UITableView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/24.
//

import UIKit

public extension UITableView {
    /// 快速 register 的方法，避免 Hard Code
    func register<T: UITableViewCell>(cellType: T.Type, reuseIdentifier: String = T.reuseIdentifier) {
        register(cellType, forCellReuseIdentifier: reuseIdentifier)
    }
    
    /// 協助 UITableViewCell 轉型 T
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T
        else {
            fatalError("❌ Cannot dequeue cell with identifier: \(cellType.reuseIdentifier)")
        }
        return cell
    }
    
    
}
