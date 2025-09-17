//
//  EmojiButton.swift
//  RemitExchange
//
//  Created by Elma YEH 葉品妤 on 2025/8/14.
//

import UIKit
import SnapKit

class EmojiButton: UIButton {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .Gray200
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.clipsToBounds = true
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = FontBook.font(.bold, fontSize: .size(12))
        label.textColor = .black
        return label
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = FontBook.font(.bold, fontSize: .size(12))
        label.textColor = .Gray500
        return label
    }()
    
    private let moreView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.clipsToBounds = true
        return view
    }()
    
    private let moreLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textAlignment = .center
        label.font = FontBook.font(.bold, fontSize: .size(12))
        label.textColor = .white
        return label
    }()
    
    var isMore: Bool = false
    
    init(emoji: String, name: String, number: String, isMore: Bool = false) {
        super.init(frame: .zero)
        setupUI(emoji: emoji, name: name, number: number, isMore: isMore)
    }
    
    required init?(coder: NSCoder) {
        fatalError("EmojiButton init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        emojiLabel.layer.cornerRadius = emojiLabel.frame.width / 2
    }
    
    private func setupUI(emoji: String, name: String, number: String, isMore: Bool) {
        
        self.addSubview(emojiLabel)
        emojiLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(emojiLabel.snp.width)
            make.centerX.equalToSuperview()
        }
        emojiLabel.text = emoji
        
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel.snp.bottom).offset(6)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        nameLabel.text = name
        
        self.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        numberLabel.text = number
        
        if isMore {
            emojiLabel.addSubview(moreView)
            moreView.snp.makeConstraints { make in
                make.top.bottom.leading.right.equalToSuperview()
            }
            
            moreView.addSubview(moreLabel)
            moreLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
}
