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
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.medium, .normal)
        label.textColor = .black
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
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
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        if !contentView.contains(titleLabel) {
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().inset(8)
                make.left.equalToSuperview().offset(14)
                make.right.equalToSuperview().inset(14)
            }
        }
    }
    
    func configure(with viewModel: CategoryItemViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.categoryName
        contentView.backgroundColor = viewModel.backgroundColor
    }
}
