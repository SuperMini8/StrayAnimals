//
//  UICollectionView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/24.
//

import UIKit

public extension UICollectionView {
    /// 快速 register 的方法，避免 Hard Code
    func register<T: UICollectionViewCell>(cellType: T.Type, reuseIdentifier: String = T.reuseIdentifier) {
        register(cellType, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /// 協助 UITableViewCell 轉型 T
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T
        else {
            fatalError("❌ Cannot dequeue cell with identifier: \(cellType.reuseIdentifier)")
        }
        return cell
    }
}

