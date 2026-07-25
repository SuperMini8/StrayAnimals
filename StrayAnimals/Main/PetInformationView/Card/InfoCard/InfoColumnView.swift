//
//  InfoColumnView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/21.
//

import  UIKit

final class InfoColumnView: UIView {
    // MARK: - UI
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2
        stackView.backgroundColor = .infoRowBackground
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }()
    
    //  MARK: - method
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("InfoColumnView init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(rows: [InfoRowViewData]) {
        
        stackView.removeAllArrangedSubview()
        
        rows.forEach {
            let rowView = InfoRowView()
            rowView.configure(with: $0)
            stackView.addArrangedSubview(rowView)
        }
    }
}
