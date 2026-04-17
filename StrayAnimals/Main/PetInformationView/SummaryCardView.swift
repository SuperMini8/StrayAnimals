//
//  SummaryCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/16.
//

import UIKit

final class SummaryCardView: UIView {
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = FontGroup.font(.bold, .large)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = FontGroup.font(.regular, .normal)
        return label
    }()
    
    private let badgesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("SummaryCardView init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
        }
        
        addSubview(badgesStackView)
        badgesStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(10)
        }
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
    }
    
}
