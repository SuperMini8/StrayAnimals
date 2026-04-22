//
//  InfoCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/21.
//

import UIKit

final class InfoCardView: PetInfoCardContainerView {
    // MARK: - UI
    private let leftColumnView = InfoColumnView()
    private let rightColumnView = InfoColumnView()
    
    private lazy var columnsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leftColumnView, rightColumnView])
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()

    // MARK: - method
    
    override func setContent() {
        titleLabel.text = "動物資訊"
        contentStackView.addArrangedSubview(columnsStackView)
    }
    
    func configure(with viewData: InfoCardViewData) {
        leftColumnView.configure(rows: viewData.leftInfoRows)
        rightColumnView.configure(rows: viewData.rightInfoRows)
    }
    
}
