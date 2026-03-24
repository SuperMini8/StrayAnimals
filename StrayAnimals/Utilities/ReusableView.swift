//
//  ReusableView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/24.
//
/// 讓可以 reuse 的 View 自帶 reuseID
public protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension ReusableView {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
