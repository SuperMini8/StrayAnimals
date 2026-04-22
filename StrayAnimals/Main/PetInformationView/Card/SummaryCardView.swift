//
//  SummaryCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/16.
//

import UIKit

final class SummaryCardView: PetInfoCardContainerView {
    // MARK: - UI
    private let subtitleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = FontGroup.font(.regular, .highLight)
        return label
    }()
    
    private let badgesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - method
    override func setContent() {
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(badgesStackView)
    }
    
    func configure(title: String, subtitle: String, badges: [BadgeViewData]) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        badgesStackView.arrangedSubviews.forEach { badge in
            badgesStackView.removeArrangedSubview(badge)
            badge.removeFromSuperview()
        }
        
        badges.forEach { badge in
            let badgeLabel = BadgeLabel(
                text: badge.text,
                font: FontGroup.font(.medium, .small),
                backgroundColor: badge.backgroundColor,
                textColor: badge.textColor,
                textAlignment: .center
            )
            badgesStackView.addArrangedSubview(badgeLabel)
        }
        /// 避免 badge 被拉伸，放一個填滿用的 View
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        badgesStackView.addArrangedSubview(spacerView)
    }
    
}
