//
//  CategoryItem.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/7.
//

import UIKit
import Combine
import SnapKit

final class CategoryItem: UICollectionViewCell {
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.medium, .small)
        label.textColor = .black
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    private let selectedImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    // MARK: - property
    private var viewModel: CategoryItemViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("CategoryItem init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
        titleLabel.text = nil
    }
    
    private func setUI() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.masksToBounds = true
        
        if !contentView.contains(titleLabel) {
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().inset(8)
                make.left.equalToSuperview().offset(10)
            }
        }
        
        if !contentView.contains(selectedImageView) {
            contentView.addSubview(selectedImageView)
            selectedImageView.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.left.equalTo(titleLabel.snp.right).offset(4)
                make.right.equalToSuperview().inset(10)
                make.width.height.equalTo(14)
            }
        }
    }
    
    func configure(with viewModel: CategoryItemViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.categoryName
        contentView.backgroundColor = viewModel.backgroundColor
        contentView.layer.borderWidth = viewModel.borderWidth
        selectedImageView.image = viewModel.selectedImage
    }
}
