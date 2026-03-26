//
//  ListCollectionViewItem.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/12/22.
//

import Foundation
import UIKit
import SnapKit
import Combine

final class ListCollectionViewItem: UICollectionViewCell {
    // MARK: - UI
    lazy private var animalImageView: UIImageView = {
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
    
    lazy private var loadingView = LoadingView()
    // MARK: - property
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: ListCollectionViewItemViewModel?
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("ListCollectionViewItem init(coder:) has not been implemented")
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
        if !contentView.contains(loadingView) {
            contentView.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalTo(animalImageView)
            }
        }
    }
    
    func configure(with viewModel: ListCollectionViewItemViewModel) {
        cancellables.removeAll()
        
        self.viewModel = viewModel
        animalKindLabel.setTextAndImage(text: viewModel.kind.displayTitleText() ,
                                        font: FontGroup.font(.regular, .small),
                                        image: viewModel.sex.sexImage(),
                                        imageArrangement: .right)
        animalStatusLabel.text = viewModel.status.statusText()
        animalAgeLabel.text = viewModel.age.AgeText()
        animalPlaceLabel.text = viewModel.place
        
        viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.animalImageView.image = image ?? viewModel.kind.defaultIamge()
            }
            .store(in: &cancellables)
        viewModel.$isImageLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
            }
            .store(in: &cancellables)
        
        setNeedsLayout()
    }
    
    // layout 都畫好後才知道實際大小
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = window?.windowScene?.screen.scale ?? UIScreen.currentFallbackScale
        viewModel?.loadImageIfNeeded(imageSize: animalImageView.bounds.size, imageScale: scale)
    }
    
}
