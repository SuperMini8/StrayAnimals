//
//  PetListItem.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import UIKit
import SnapKit
import Combine

final class PetListItem: UICollectionViewCell {
    // MARK: - UI
    private let animalImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let animalKindLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    private let animalVarietyLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    private let animalStatusLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    private let animalAgeLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    private let animalPlaceLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.regular, .small)
        return label
    }()
    
    private lazy var loadingView = LoadingView(style: .medium)
    // MARK: - property
    private var viewModel: PetListItemViewModel?
    private var cancellables = Set<AnyCancellable>()
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("PetListItem init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        /// 取消舊訂閱
        cancellables.removeAll()
        animalImageView.image = nil
        animalKindLabel.text = nil
        animalStatusLabel.text = nil
        animalAgeLabel.text = nil
        animalPlaceLabel.text = nil
    }
        
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.border.cgColor
        clipsToBounds = true
        
        if !contentView.contains(animalImageView) {
            contentView.addSubview(animalImageView)
            animalImageView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.width.height.equalTo(contentView.snp.width)
            }
        }
        if !contentView.contains(animalKindLabel) {
            contentView.addSubview(animalKindLabel)
            animalKindLabel.snp.makeConstraints { make in
                make.top.equalTo(animalImageView.snp.bottom).offset(3)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
            }
        }
        if !contentView.contains(animalVarietyLabel) {
            contentView.addSubview(animalVarietyLabel)
            animalVarietyLabel.snp.makeConstraints { make in
                make.top.equalTo(animalKindLabel.snp.bottom).offset(3)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
            }
        }
        if !contentView.contains(animalStatusLabel) {
            contentView.addSubview(animalStatusLabel)
            animalStatusLabel.snp.makeConstraints { make in
                make.top.equalTo(animalVarietyLabel.snp.bottom).offset(3)
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
        if !contentView.contains(loadingView) {
            contentView.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalTo(animalImageView)
            }
        }
    }
    
    func configure(with viewModel: PetListItemViewModel) {
        cancellables.removeAll()
        
        self.viewModel = viewModel
        animalKindLabel.setTextAndImage(text: viewModel.kindText ,
                                        font: FontGroup.font(.regular, .small),
                                        image: viewModel.sex.sexImage(),
                                        imageArrangement: .right)
        animalVarietyLabel.text = viewModel.variety
        animalStatusLabel.text = viewModel.status.statusText()
        animalAgeLabel.text = viewModel.age
        animalPlaceLabel.text = viewModel.place
        
        viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.animalImageView.image = image ?? viewModel.kindImage
            }
            .store(in: &cancellables)
        viewModel.$isImageLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
            }
            .store(in: &cancellables)
        
        startDownloadImage()
    }
    
    // 開始下載圖片
    func startDownloadImage() {
        super.layoutSubviews()
        let scale = window?.windowScene?.screen.scale ?? UIScreen.currentFallbackScale
        viewModel?.loadImageIfNeeded(imageSize: .thumbnail, imageScale: scale)
    }
    
}
