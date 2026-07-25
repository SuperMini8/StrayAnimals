//
//  ShelterCardView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/22.
//

import UIKit

final class ShelterCardView: PetInfoCardContainerView {
    // MARK: - UI
    private let shelterNameLabel = IconTitleValueView()
    private let shelterAddressLabel = IconTitleValueView()
    private let shelterPhoneLabel = IconTitleValueView()
    let bottomButtonView = BottomActionView()
    
    override func setContent() {
        titleLabel.text = "收容資訊"
        contentStackView.addArrangedSubview(shelterNameLabel)
        contentStackView.addArrangedSubview(shelterAddressLabel)
        contentStackView.addArrangedSubview(shelterPhoneLabel)
        contentStackView.addArrangedSubview(bottomButtonView)
    }
    
    func configure(with viewData: ShelterCardViewData) {
        if viewData.name.isEmpty != true {
            shelterNameLabel.configure(
                icon: UIImage.shelter,
                titleText: nil,
                valueText: viewData.name
            )
        } else {
            contentStackView.removeArrangedSubviewCompletely(shelterNameLabel)
        }
        
        if viewData.adderss.isEmpty != true {
            shelterAddressLabel.configure(
                icon: UIImage.location,
                titleText: nil,
                valueText: viewData.adderss
            )
        } else {
            contentStackView.removeArrangedSubviewCompletely(shelterAddressLabel)
        }
        
        if viewData.phone.isEmpty != true {
            shelterPhoneLabel.configure(
                icon: UIImage.phone,
                titleText: nil,
                valueText: viewData.phone
            )
        } else {
            contentStackView.removeArrangedSubviewCompletely(shelterPhoneLabel)
        }
        
        bottomButtonView.configure(
            leftBtn: .outlined(title: "查看地址", image: UIImage.map),
            rightBtn: .filled(title: "聯絡收容所", image: UIImage.phone),
        )
    }
    
}

