//
//  PetInfoCardContainerView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/22.
//

import UIKit
/// 共用 UI 樣式的 class，只 focus 給 PetInformationView 用的
class PetInfoCardContainerView: UIView {
     // MARK: - UI
    let titleLabel: UILabel = {
       let label = UILabel()
        label.font = FontGroup.font(.bold, .large)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
         stackView.axis = .vertical
         stackView.spacing = 8
         return stackView
    }()
    
    private let rootStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("PetInfoCardContainerView init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        clipsToBounds = true
        
        addSubview(rootStackView)
        rootStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
        }
        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(contentStackView)
    }
    
    // MARK: - Override Points
    func setContent() {}
    
}
