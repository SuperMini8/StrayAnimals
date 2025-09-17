//
//  AccountInputView.swift
//  CrossPay
//
//  Created by Lily TSAI 蔡佳玲 on 2025/7/30.
//

import UIKit

enum InputState: Equatable {
    case normal
    case error(String?)
    case success
}

extension InputState {
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

class AccountInputView: UIView {
    
    private var onlyInputNumber: Bool = false
    private var onlyInputChinese: Bool = false
    private var onlyInputEnglish: Bool = false
    
    private var hinterText: String?
    
    var customValidation: ((String) -> String?)?
    
    var inputState: InputState = .normal
    
    var isRulesStyle: Bool = false
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
   
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font =  FontBook.font(.medium, fontSize: .small)
        label.numberOfLines = 1
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.Gray400.cgColor
        textField.font = FontBook.font(.medium, fontSize: .small)
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.delegate = self
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var hintButton: UIButton = {
        let btn = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(named: "icon_hint_alert")
        config.imagePadding = 4
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = FontBook.font(.regular, fontSize: .size(12))
            return outgoing
        }

        config.attributedTitle = AttributedString("")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        config.baseBackgroundColor = .clear
        
        btn.configuration = config
        btn.contentHorizontalAlignment = .leading
        btn.contentVerticalAlignment = .center
        btn.isHidden = true
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    func setup(header: String = "", headerAttributed: NSAttributedString? = nil,
               placeholder: String, isPicker: Bool = false, inputTxtColor: UIColor = .black,
               image: UIImage? = UIImage(named: "icon_arrow_expand")) {
        self.headerLabel.text = header
        if let headerAttributed = headerAttributed {
            self.headerLabel.attributedText = headerAttributed
        }
        self.inputTextField.placeholder = placeholder
        self.inputTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            .foregroundColor: UIColor.Gray500,
            .font: FontBook.font(.regular, fontSize: .small)
        ])
      
        self.rightButton.isHidden = !isPicker
        if isPicker {
            self.rightButton.setImage(image, for: .normal)
            self.addSubview(rightButton)
            rightButton.trailingAnchor.constraint(equalTo: inputTextField.trailingAnchor, constant: -12).isActive = true
            rightButton.topAnchor.constraint(equalTo: inputTextField.topAnchor, constant: 12).isActive = true
            rightButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
            rightButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
            self.inputTextField.tintColor = inputTxtColor
        }
       
    }
    
    func setupHint(isHintHidden: Bool = true, hinter: String?, txtColor:UIColor = UIColor.Red,
                   image: UIImage? = UIImage(named: "icon_hint_alert"), isRulesStyle: Bool = false) {
        self.hinterText = hinter
        if let text = hinter {
            hintButton.setTitle(text, for: .normal)
            hintButton.setTitleColor(.Gray500, for: .normal)
            hintButton.isHidden = false
            if var config = hintButton.configuration {
                config.image = image
                hintButton.configuration = config
            }

        } else {
            hintButton.isHidden = true
        }
        self.isRulesStyle = isRulesStyle
    }
    
    func updateState(_ state: InputState, focused: Bool = false) {
        switch state {
        case .normal:
            hintButton.isHidden = hinterText == nil
            hintButton.setTitle(hinterText, for: .normal)
            hintButton.setTitleColor(.Gray500, for: .normal)
            
        case .error(_):
            hintButton.isHidden = false
            if let rule = hinterText {
                hintButton.setTitle(rule, for: .normal)
            } else if let errorMessage = state.errorMessage {
                hintButton.setTitle(errorMessage, for: .normal)
            }
            hintButton.setTitleColor(.Red, for: .normal)
            
        case .success:
            hintButton.isHidden = hinterText == nil
            hintButton.setTitle(hinterText, for: .normal)
            hintButton.setTitleColor(.Green, for: .normal)
        }
        
        if focused {
            inputTextField.layer.borderColor = UIColor.Blue.cgColor
            if isRulesStyle {
                hintButton.isHidden = false
                hintButton.setTitleColor(.Gray500, for: .normal)
            }else {
                hintButton.isHidden = true
            }
        } else {
            switch state {
            case .normal:
                inputTextField.layer.borderColor = UIColor.Gray500.cgColor
            case .error(_):
                inputTextField.layer.borderColor = UIColor.red.cgColor
            case .success:
                inputTextField.layer.borderColor = UIColor.Gray500.cgColor
            }
        }
    }
    
    func updateDropDownArrow(focused: Bool = false) {
        if focused {
            rightButton.setImage(UIImage(named: "icon_arrow_expand_focus"), for: .normal)
        } else{
            rightButton.setImage(UIImage(named: "icon_arrow_expand"), for: .normal)
        }
    }
    
    func validateTextfield(focused: Bool = false) {
        guard let text = inputTextField.text else { return }
        
        if text.isEmpty {
            updateState(.normal, focused: focused)
            inputState = .normal
        } else if let errorMessage = customValidation?(text) {
            updateState(.error(errorMessage), focused: focused)
            inputState = .error(errorMessage)
        } else {
            updateState(.success, focused: focused)
            inputState = .success
        }
        
    }
    
    func setInputRestrictions(number: Bool, chinese: Bool, english: Bool) {
        onlyInputNumber = number
        onlyInputChinese = chinese
        onlyInputEnglish = english
        
        if onlyInputNumber || onlyInputChinese || onlyInputEnglish {
            enableNotification()
        } else {
            disableNotification()
        }
    }
    
    private func enableNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.greetingTextFieldChanged), name: UITextField.textDidChangeNotification, object: self.inputTextField)
    }
    
    private func disableNotification() {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: self.inputTextField)
    }
    
    private func updateInputTextFieldTopAnchor(isHintHidden: Bool) {
        hintButton.isHidden = isHintHidden
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        verticalStackView.addArrangeSubviews([headerLabel, inputTextField, hintButton])
        self.addSubview(verticalStackView)
        inputTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @objc private func btnAction() {
        self.inputTextField.becomeFirstResponder()
    }
    
    func reloadPickerViewComponent() {
        if let pickerView = inputTextField.inputView as? UIPickerView {
            pickerView.reloadAllComponents()
        }
    }
    
    @objc func greetingTextFieldChanged(obj: Notification) {
        if inputTextField.markedTextRange != nil {
            return
        }
        
        let cursorPosition = inputTextField.offset(from: inputTextField.endOfDocument,
                                                   to: inputTextField.selectedTextRange!.end)
        
        var pattern = "[^"
        if onlyInputNumber { pattern += "0-9" }
        if onlyInputEnglish { pattern += "a-zA-Z" }
        if onlyInputChinese { pattern += "\\u4E00-\\u9FA5" }
        pattern += "]"
        
        if let text = inputTextField.text {
            let filtered = text.pregReplace(pattern: pattern, with: "")
            inputTextField.text = filtered
        }
        
        if let newPosition = inputTextField.position(from: inputTextField.endOfDocument, offset: cursorPosition) {
            inputTextField.selectedTextRange = inputTextField.textRange(from: newPosition, to: newPosition)
        }
    }

}
extension AccountInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.validateTextfield(focused: true)
        self.reloadPickerViewComponent()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateTextfield(focused: false)
    }
}

