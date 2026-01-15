//
//  ListCollectionViewItem.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import UIKit
import SnapKit

class ListCollectionViewItem: UICollectionViewCell {
    
    static let cellID: String = "ListCollectionViewItem"
        
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var animalKindLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    lazy private var animalStatusLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    lazy private var animalAgeLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    lazy private var animalPlaceLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    var viewModel: PetData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("ListCollectionViewItem init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
        
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        
        if !contentView.contains(imageView) {
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.width.height.equalTo(contentView.snp.width)
            }
        }
        if !contentView.contains(animalKindLabel) {
            contentView.addSubview(animalKindLabel)
            animalKindLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(3)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
            }
        }
        if !contentView.contains(animalStatusLabel) {
            contentView.addSubview(animalStatusLabel)
            animalStatusLabel.snp.makeConstraints { make in
                make.top.equalTo(animalKindLabel.snp.bottom).offset(3)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
            }
        }
        if !contentView.contains(animalAgeLabel) {
            contentView.addSubview(animalAgeLabel)
            animalAgeLabel.snp.makeConstraints { make in
                make.top.equalTo(animalStatusLabel.snp.bottom).offset(3)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
            }
        }
        if !contentView.contains(animalPlaceLabel) {
            contentView.addSubview(animalPlaceLabel)
            animalPlaceLabel.snp.makeConstraints { make in
                make.top.equalTo(animalAgeLabel.snp.bottom).offset(3)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
                make.bottom.greaterThanOrEqualTo(contentView).offset(-3)
            }
        }
    }
    
    func configure(vm: PetData?) {
        viewModel = vm
        imageView.image = vm?.animal_kind.defaultIamge()
        animalKindLabel.setTextAndImage(text: vm?.animal_kind.displayTitleText() ?? "",
                                        font: FontGroup.font(.regular, .small),
                                        imageName: vm?.animal_sex.sexImageName() ?? "",
                                        imageArrangement: .right)
        animalStatusLabel.text = vm?.animal_status.statusText()
        animalAgeLabel.text = vm?.animal_age.AgeText()
        animalPlaceLabel.text = vm?.animal_place
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    
}
