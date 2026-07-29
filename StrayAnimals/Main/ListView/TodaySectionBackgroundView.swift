//
//  TodaySectionBackgroundView.swift
//  StrayAnimals
//
//  Created by Codex on 2026/7/29.
//

import UIKit

final class TodaySectionBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("TodaySectionBackgroundView init(coder:) has not been implemented")
    }

    private func setUI() {
        // 今日更新 section 背後的色帶，讓這一區和一般列表有明顯區隔
        backgroundColor = UIColor(red: 1.0, green: 0.89, blue: 0.46, alpha: 0.45)
        layer.borderColor = UIColor(red: 0.95, green: 0.72, blue: 0.18, alpha: 0.45).cgColor
        layer.borderWidth = 1
    }
}
