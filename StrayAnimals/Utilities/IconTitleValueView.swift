//
//  IconTitleValueView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/22.
//

import UIKit

final class IconTitleValueView: UIView {
    // MARK: - UI
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .medium)
        label.textColor = .infoCardTitle
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.medium, .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel, valueLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .firstBaseline
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("IconTitleValueView init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .clear
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }
    
    func configure(icon: UIImage?, titleText: String?, valueText: String?) {
        if let icon {
            iconImageView.image = icon
        } else {
            stackView.removeArrangedSubview(iconImageView)
        }
        
        if let titleText {
            titleLabel.text = titleText
        } else {
            stackView.removeArrangedSubview(titleLabel)
        }
        
        if let valueText {
            valueLabel.text = valueText
        } else {
            stackView.removeArrangedSubview(valueLabel)
        }
    }
}
