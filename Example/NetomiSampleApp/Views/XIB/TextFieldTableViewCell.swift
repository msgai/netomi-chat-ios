//
//  TextFieldTableViewCell.swift
//  NetomiSampleApp
//
//  Created by Netomi on 18/11/24.
//

import UIKit

class FloatingTextFieldItem {
    var title: String?
    var placeholder: String?
    var text: String?
    var isEnable: Bool = true
    var leftMessage: String? = nil
    var leftImage: UIImage? = nil
    var leftDivider: Bool = false
    var rightImage: UIImage? = nil
    var isSelectable: Bool = false
    var isMandatory: Bool = false
    var key: String?
    var errorMsg: String?
    var acceptType: TextValidation = .none()
    
    init(title: String? = nil,placeholder: String? = nil, text: String? = nil, isEnable: Bool = true, leftMessage: String? = nil, leftImage: UIImage? = nil, leftDivider: Bool = false, rightImage: UIImage? = nil, isSelectable: Bool = false, isMandatory: Bool = false, key: String? = nil, acceptType: TextValidation = .none(), errorMsg: String? = nil) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.isEnable = isEnable
        self.leftMessage = leftMessage
        self.leftImage = leftImage
        self.leftDivider = leftDivider
        self.rightImage = rightImage
        self.isSelectable = isSelectable
        self.isMandatory = isMandatory
        self.key = key
        self.acceptType = acceptType
        self.errorMsg = errorMsg
    }
}

class TextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: NSATextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorBtn: UIButton!
    @IBOutlet weak var errorMsgView: UIStackView!
    
    var editingChanged: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var configure: FloatingTextFieldItem? {
        didSet {
            titleLabel.text = configure?.title ?? ""
            textField.placeholder = configure?.placeholder ?? ""
            
            if let key = configure?.key, key == "password" {
                textField.textInput.isSecureTextEntry = true
            }
            
            let attributedString = NSAttributedString(string: configure?.errorMsg ?? "")
            errorBtn.setAttributedTitle(attributedString, for: .normal)
            
            textField.text = configure?.text ?? ""
            textField.isEnable = configure?.isEnable ?? true
            textField.leftViewMessage = configure?.leftMessage ?? ""
            textField.leftViewImage = configure?.leftImage
            textField.showLeftViewDivider = configure?.leftDivider ?? false
            textField.rightImage = configure?.rightImage
            textField.isSelectable = configure?.isSelectable ?? false
            textField.acceptType = configure?.acceptType ?? .none()
            
            switch configure?.acceptType {
            case .alphabets:
                textField.textInput.keyboardType = .alphabet
                textField.textInput.spellCheckingType = .no
                textField.textInput.autocorrectionType = .no
            case .phone:
                textField.textInput.keyboardType = .phonePad
            case .alphaNumeric:
                textField.textInput.keyboardType = .asciiCapable
                textField.textInput.spellCheckingType = .no
                textField.textInput.autocorrectionType = .no
            default:
                textField.textInput.spellCheckingType = .no
                textField.textInput.autocorrectionType = .no
                textField.textInput.keyboardType = .default
            }
            
            textField.editingChanged = { [weak self] text in
                self?.configure?.text = text
                self?.editingChanged?()
            }
            
            textField.rightViewAction = {[weak self] in
                guard let self = self else { return }
                self.textField.textInput.isSecureTextEntry.toggle()
                self.textField.rightImage = self.textField.textInput.isSecureTextEntry ? AppImages.hidePassword : AppImages.showPassword
            }
            
            textField.textFieldDidBeginEditing = {[weak self] in
                guard let self = self else { return }
                self.errorMsgView.isHidden ? self.validField() : self.invalidFiled()
            }
            
            textField.textFieldDidEndEditing = { [weak self] in
                guard let self = self else { return }
                self.errorMsgView.isHidden ? () : self.invalidFiled()
            }
            setupToolbars()

        }
    }
    
    func validField(){
        textField.validField()
    }
    
    func invalidFiled(){
        textField.invalidField()
    }
    private func setupToolbars() {
        // attach to the inner UITextFields
        textField.textInput.addDoneToolbar(target: self, action: #selector(dismissKeyboard))
    }
    
    @objc private func dismissKeyboard() {
        textField.textInput.resignFirstResponder()
    }
    
}
