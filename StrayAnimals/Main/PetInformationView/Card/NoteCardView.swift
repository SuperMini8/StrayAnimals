//
//  NoteCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/22.
//

import UIKit

final class NoteCardView: PetInfoCardContainerView {
    // MARK: - UI
    private let foundPlaceLabel = IconTitleValueView()
    private let remarkLabel = IconTitleValueView()
    private let updateDateLabel = IconTitleValueView()
    
    // MARK: - method
    override func setContent() {
        titleLabel.text = "補充說明"
        contentStackView.addArrangedSubview(foundPlaceLabel)
        contentStackView.addArrangedSubview(remarkLabel)
        contentStackView.addArrangedSubview(updateDateLabel)
    }
    
    func configure(with viewData: NoteCardViewData) {
        /// 沒有資料不顯示
        if viewData.foundPlace.isEmpty != true {
            foundPlaceLabel.configure(
                icon: UIImage.questionMark,
                titleText: "發現地點：",
                valueText: viewData.foundPlace
            )
        } else {
            contentStackView.removeArrangedSubview(foundPlaceLabel)
        }
        
        if viewData.remark.isEmpty != true {
            remarkLabel.configure(
                icon: UIImage.questionMark,
                titleText: "備註：",
                valueText: viewData.remark
            )
        } else {
            contentStackView.removeArrangedSubview(remarkLabel)
        }
        
        if let updateDateText = viewData.updateDateText {
            updateDateLabel.configure(
                icon: UIImage.questionMark,
                titleText: "資料更新：",
                valueText: updateDateText
            )
        } else {
            contentStackView.removeArrangedSubview(updateDateLabel)
        }
        
        /// 如果都沒有資料就把自己移除
        if contentStackView.arrangedSubviews.isEmpty {
            self.removeFromSuperview()
        }
    }


}
