//
//  BottomActionView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/22.
//

import UIKit

final class BottomActionView: UIView {
    // MARK: - UI
    private var leftButton = UIButton()
    
    private var rightButton = UIButton()
    
    private lazy var contentSteckView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leftButton, rightButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }()

    // MARK: - property
    var leftButtonOnTap: ((UIView) -> Void)?
    var rightButtonOnTap: ((UIView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("BottomActionView init(coder:) has not been implemented")
    }
    
    
    private func setUI() {
        addSubview(contentSteckView)
        contentSteckView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        leftButton.addTarget(self, action: #selector(leftDidTap(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightDidTap(_:)), for: .touchUpInside)
    }
    
    func configure(
        leftBtn: ActionButtonStyle,
        rightBtn: ActionButtonStyle,
        stackViewDistribution: UIStackView.Distribution = .fillEqually
    ) {
        leftButton.setConfiguration(style: leftBtn)
        rightButton.setConfiguration(style: rightBtn)
        contentSteckView.distribution = stackViewDistribution
    }
    /// 設定左邊按鈕是否可以點擊
    func setLeftButtonEnable(_ isEnable: Bool) {
        leftButton.isEnabled = isEnable
    }
    /// 設定右邊按鈕是否可以點擊
    func setRightButtonEnable(_ isEnable: Bool) {
        rightButton.isEnabled = isEnable
    }
    
    @objc private func leftDidTap(_ sender: UIButton) {
        leftButtonOnTap?(sender)
    }
    
    @objc private func rightDidTap(_ sender: UIButton) {
        rightButtonOnTap?(sender)
    }
}
