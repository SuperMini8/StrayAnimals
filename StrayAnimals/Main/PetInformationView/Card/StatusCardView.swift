//
//  StatusCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/17.
//

import UIKit

final class StatusCardView: PetInfoCardContainerView {
    // MARK: UI
    private let statusLabel: BadgeLabel = BadgeLabel()
    private let openDateView: IconTitleValueView = IconTitleValueView()
    private let updateDateView: IconTitleValueView = IconTitleValueView()
    
    // MARK: - method
    override func setContent() {
        titleLabel.text = "認養狀態"
        contentStackView.addArrangedSubview(statusLabel)
        contentStackView.addArrangedSubview(openDateView)
        contentStackView.addArrangedSubview(updateDateView)
    }
    
    func configure(with data: StatusCardViewData) {
        
        statusLabel.updateLabel(
            text: data.statusText,
            font: FontGroup.font(.bold, .highLight),
            backgroundColor: data.statusBackgroundColor,
            textColor: data.statusTextColor,
            textAlignment: .left
        )
        
        openDateView.isHidden = (data.openDateText == nil)
        if let openText = data.openDateText {
            openDateView.configure(
                icon: UIImage.date,
                titleText: "開放時間",
                valueText: openText
            )
        }
        
        updateDateView.isHidden = (data.updateDateText == nil)
        if let updateText = data.updateDateText {
            updateDateView.configure(
                icon: UIImage.update,
                titleText: "最後更新",
                valueText: updateText
            )
        } 
    }
    
    
}
