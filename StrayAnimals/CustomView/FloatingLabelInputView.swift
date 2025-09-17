//
//  titleTextfield.swift
//  RemitExchange
//
//  Created by Elma YEH 葉品妤 on 2025/8/20.
//

import UIKit
import SnapKit

enum FloatingLabelInputState {
    case noText
    case haveText
    case focused
    case error
}

class FloatingLabelInputView: UIView, UITextFieldDelegate {
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.Gray400.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 48))
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.tintColor = .Blue
        textField.font = FontBook.font(.regular, fontSize: .normal)
        textField.delegate = self
        return textField
    }()
    
    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Gray500
        label.font = FontBook.font(.regular, fontSize: .normal)
        label.backgroundColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var rightButton: UIView = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        button.setImage(UIImage(named: "icon_password_invisible"), for: .normal)
        button.setImage(UIImage(named: "icon_password_visible"), for: .selected)
        button.addTarget(self, action: #selector(clickRightButton(button:)), for: .touchUpInside)
        let view = UIView(frame: button.frame)
        view.addSubview(button)
        return view
    }()
    
    private let placeholder: String
    private let isSecurityTextEntry: Bool
    private var isError: Bool = false
    var onTextEndEdit: ((String) -> Void)?
    var onTextChanging: ((String) -> Bool)?
    
    init(placeholder: String = "", isSecurityTextEntry: Bool = false) {
        self.placeholder = placeholder
        self.isSecurityTextEntry = isSecurityTextEntry
        super.init(frame: .zero)
        setupUI()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("FloatingLabelInputView init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        addSubview(inputTextField)
        inputTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.left.right.equalToSuperview()
        }
        if isSecurityTextEntry {
            inputTextField.isSecureTextEntry = true
            inputTextField.rightView = rightButton
            inputTextField.rightViewMode = .always
        }
        
        addSubview(floatingLabel)
        floatingLabel.snp.makeConstraints { make in
            make.top.equalTo(inputTextField).offset(12)
            make.bottom.equalTo(inputTextField).offset(-12)
            make.left.equalTo(inputTextField).offset(16)
        }
        floatingLabel.text = " \(placeholder) "
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeActive))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func becomeActive() {
        inputTextField.becomeFirstResponder()
    }
    
    @objc private func clickRightButton(button: UIButton) {
        inputTextField.isSecureTextEntry.toggle()
        button.isSelected.toggle()
    }
    
    func getText() -> String {
        return inputTextField.text ?? ""
    }
    
    func setIsError(isError: Bool) {
        self.isError = isError
        if isError {
            setState(.error)
        } else {
            setState(.haveText)
        }
    }
    
    func setState(_ state: FloatingLabelInputState) {
        switch state {
        case .noText:
            inputTextField.layer.borderColor = UIColor.Gray400.cgColor
            floatingLabel.textColor = .Gray500
        case .haveText:
            inputTextField.layer.borderColor = UIColor.Gray400.cgColor
            floatingLabel.textColor = .Gray800
        case .focused:
            inputTextField.layer.borderColor = UIColor.Blue.cgColor
            floatingLabel.textColor = .Blue
        case .error:
            inputTextField.layer.borderColor = UIColor.red.cgColor
            floatingLabel.textColor = .red
        }
    }
    
    func clearText() {
        inputTextField.text = ""
        setState(.noText)
        isError = false
        animateLabel()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateLabel()
        setState(.focused)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text, let range = Range(range, in: text) else { return true }
        let newText = text.replacingCharacters(in: range, with: string)        
        return onTextChanging?(newText) ?? true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateLabel()
        
        guard let text = textField.text else { return }
        onTextEndEdit?(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func animateLabel() {
        let shouldFloat = inputTextField.isFirstResponder || !(inputTextField.text?.isEmpty ?? true)
        let offsetX = -(self.floatingLabel.bounds.width*0.1 / 2)
        let offsetY = -(self.bounds.height / 2)
        UIView.animate(withDuration: 0.2) {
            self.floatingLabel.transform = shouldFloat ? CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: offsetX, y: offsetY) : .identity
        }
    }
}

