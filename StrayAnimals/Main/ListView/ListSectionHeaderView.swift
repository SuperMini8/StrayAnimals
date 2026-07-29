//
//  ListSectionHeaderView.swift
//  StrayAnimals
//
//  Created by Codex on 2026/7/29.
//

import UIKit
import SnapKit

final class ListSectionHeaderView: UICollectionReusableView {
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.bold, .medium)
        label.textColor = .label
        return label
    }()

    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("ListSectionHeaderView init(coder:) has not been implemented")
    }

    private func setUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            // 讓文字貼近 Header 底部，避免文字與 TodayCell 距離太遠
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
    }

    func configure(title: String?) {
        // nil 代表這個 Header 不需要顯示文字
        titleLabel.text = title
    }
}
