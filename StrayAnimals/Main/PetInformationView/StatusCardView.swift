//
//  StatusCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/17.
//

import UIKit

final class StatusCardView: UIView {
    // MARK: UI
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "認養狀態"
        label.font = FontGroup.font(.bold, .large)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let statusLabel: BadgeLabel = BadgeLabel()
    
    private let openDateLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("StatusCardView init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(statusLabel)
        containerStackView.addArrangedSubview(openDateLabel)
        
//        addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(10)
//            make.left.equalToSuperview().offset(12)
//            make.right.equalToSuperview().inset(12)
//        }
//        
//        addSubview(statusLabel)
//        statusLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(4)
//            make.left.equalToSuperview().offset(12)
//            make.right.equalToSuperview().inset(12)
//        }
//        
//        addSubview(openDateLabel)
//        openDateLabel.snp.makeConstraints { make in
//            make.top.equalTo(statusLabel.snp.bottom).offset(4)
//            make.left.equalToSuperview().offset(22)
//            make.right.equalToSuperview().inset(22)
//            make.bottom.equalToSuperview().inset(10)
//        }
        
    }
    
    func configure(with data: StatusCardViewData) {
        
        statusLabel.updateLabel(
            text: data.statusText,
            font: FontGroup.font(.medium, .normal),
            backgroundColor: data.statusBackgroundColor,
            textColor: data.statusTextColor,
            textAlignment: .left
        )
        
        if let openText = data.openDateText {
            openDateLabel.setTextAndImage(
                text: "開放認養時間：" + openText,
                font: FontGroup.font(.regular, .small),
                image: UIImage.cat,
                imageArrangement: .left
            )
        } else {
            containerStackView.removeArrangedSubview(openDateLabel)
        }
    }
    
    
}
