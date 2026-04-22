//
//  InfoRowView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/21.
//

import UIKit

final class InfoRowView: UIView {
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        label.textColor = .infoRowTitle
        label.numberOfLines = 1
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.bold, .small)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("InfoRowView init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .clear
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
    }
    
    func configure(with viewData: InfoRowViewData) {
        titleLabel.text = viewData.title
        valueLabel.text = viewData.value
    }
}
