//
//  OPTInputView.swift
//  RemitExchange
//
//  Created by Lily TSAI 蔡佳玲 on 2025/8/15.
//

import UIKit

class OTPInputView: UIView, UITextFieldDelegate {
    ///紅匡 error 補上
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.font(.bold, fontSize: .size(15))
        label.text = "Please enter the 6-digit verification code sent via SMS to"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var hiddenTextField:UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.delegate = self
        textField.tintColor = .clear
        textField.textColor = .clear
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private var HstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        
        return stackView
    }()
    
    private var digitLabels = [UILabel]()
    private let numberOfDigits: Int
    
    var onCodeEntered: ((String) -> Void)?

    init(numberOfDigits:Int = 6) {
        self.numberOfDigits = numberOfDigits
        super.init(frame: .zero)
        setupView()
        addTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubviews([titleLabel, HstackView, hiddenTextField])
        
        for _ in 0..<numberOfDigits {
            let label = UILabel()
            label.textAlignment = .center
            label.font = FontBook.font(.bold, fontSize: .size(17))
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 16
            label.layer.borderColor = UIColor.Gray400.cgColor
            label.clipsToBounds = true
            label.backgroundColor = .white
            HstackView.addArrangeSubviews([label])
            digitLabels.append(label)
            
            label.snp.makeConstraints { make in
                make.height.equalTo(label.snp.width)
            }
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(50)
        }
        HstackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().priority(.low)
        }

    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeActive))
        self.addGestureRecognizer(tap)
    }

    @objc func becomeActive() {
        hiddenTextField.becomeFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if newText.count > numberOfDigits { return false }
        updateLabels(with: newText)

        if newText.count == numberOfDigits {
            onCodeEntered?(newText)
        }

        return true
    }

    private func updateLabels(with text: String) {
        for i in 0..<digitLabels.count {
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                digitLabels[i].text = String(text[index])
            } else {
                digitLabels[i].text = ""
            }
        }
    }

    func setupPhoneNumber(phone: String) {
        let maskPhoneString = Utility.mask(phone, visiblePrefix: 4, visibleSuffix: 3)
        titleLabel.text = "Please enter the 6-digit verification code sent via SMS to " + maskPhoneString
    }
    
    func getCode() -> String {
        return hiddenTextField.text ?? ""
    }

    func clear() {
        hiddenTextField.text = ""
        updateLabels(with: "")
    }
}
