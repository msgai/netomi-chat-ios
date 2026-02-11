//
//  NSATextField.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import Foundation
import UIKit

enum TextValidation {
    case alphabets(min: Int = 1, max: Int = 75)
    case phone
    case number(min: Int = 1, max: Int)
    case lengthNumber(lenght: Int, value: Int)
    case alphaNumericSpace(min: Int = 1, max: Int = 75)
    case alphaNumeric(min: Int = 1, max: Int = 75)
    case id(min: Int = 1, max: Int = 10)
    case none(min: Int = 0, max: Int = 75)
    
    var rawValidation: String {
        switch self {
        case .alphabets:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz"
        case .phone:
            return "+0123456789"
        case .number:
            return "0123456789"
        case .lengthNumber:
            return "0123456789"
        case .alphaNumericSpace:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz0123456789"
        case .alphaNumeric:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        case .id:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        case .none:
            return ""
        }
    }
    
    var allowedCharacters: CharacterSet? {
        switch self {
        case .alphabets: return CharacterSet.letters.union(.whitespaces)
        case .phone: return CharacterSet(charactersIn: "+0123456789")
        case .number, .lengthNumber: return CharacterSet.decimalDigits
        case .alphaNumericSpace: return CharacterSet.alphanumerics.union(.whitespaces)
        case .alphaNumeric: return CharacterSet.alphanumerics
        case .id: return CharacterSet.uppercaseLetters.union(.decimalDigits)
        case .none: return nil
        }
    }

    var maxLength: Int? {
        switch self {
        case .alphabets(_, let max),
             .number(_, let max),
             .alphaNumericSpace(_, let max),
             .alphaNumeric(_, let max),
             .id(_, let max),
             .none(_, let max):
            return max
        case .phone:
            return 11
        case .lengthNumber(let length, _):
            return length
        }
    }

}

class NSATextField: UIView, UITextFieldDelegate {
    
    private var containerView: NSAView!
    var textInput: UITextField!
    private var placeholderLbl: UIButton!
    private var selectionBtn: UIButton!
    
    var acceptType: TextValidation = .none()
    
    @IBInspectable var placeholder: String? {
        get {
            return textInput?.placeholder
        }
        set {
            textInput?.placeholder = newValue
            managePlaceholder()
        }
    }
       
    private var inlinePlaceholderValue: String?
    @IBInspectable var inlinePlaceholder: String? {
        get {
            return inlinePlaceholderValue
        }
        set {
            inlinePlaceholderValue = newValue
            managePlaceholder()
        }
    }
     
    @IBInspectable var text: String? {
        get {
            return self.textInput?.text
        }
        set {
            self.textInput?.text = newValue
            managePlaceholder()
        }
    }
    
    @IBInspectable var textColor: UIColor? {
        get {
            return self.textInput?.textColor
        }
        set {
            self.textInput?.textColor = newValue
        }
    }
    
    @IBInspectable var activeColor: UIColor? = UIColor.black//AppColors.themeColor
    
    @IBInspectable var inActiveColor: UIColor? = UIColor.gray//AppColors.textGray
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    func initialSetup() {
        setupPlaceholderLabel()
        setupContainerView()
        setupInputView()
        setupActionButton()
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholder()
    }
    
    private func setupPlaceholderLabel() {
        placeholderLbl = UIButton()
        placeholderLbl.translatesAutoresizingMaskIntoConstraints = false
        placeholderLbl.setTitleColor(activeColor, for: .normal)
        placeholderLbl.backgroundColor = UIColor.blue//AppColors.themeWhite
       // placeholderLbl.titleLabel?.font = AppFonts.medium.withSize(13)
        managePlaceholder()
        self.addSubview(placeholderLbl)
        NSLayoutConstraint.activate([
            (placeholderLbl.heightAnchor.constraint(equalToConstant: 20)),
            (placeholderLbl.topAnchor.constraint(equalTo: self.topAnchor)),
            (placeholderLbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)),
            (placeholderLbl.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -12))
        ])
    }
    
    private func setupContainerView() {
        self.backgroundColor = .clear
        containerView = NSAView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.borderWidth = 0.4
        containerView.borderColor = inActiveColor
        containerView.cornerRadius = 16
        self.addSubview(containerView)
        NSLayoutConstraint.activate([
            (containerView.topAnchor.constraint(equalTo: self.placeholderLbl.centerYAnchor)),
            (containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)),
            (containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor)),
            (containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor))
        ])
        bringSubviewToFront(placeholderLbl)
    }

    
    private func setupInputView() {
        textInput = UITextField()
        textInput.delegate = self
        textInput.translatesAutoresizingMaskIntoConstraints = false
        textInput.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        textInput.textColor = UIColor.black
        textInput.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        containerView.addSubview(textInput)
        NSLayoutConstraint.activate([
            (textInput.topAnchor.constraint(equalTo: containerView.topAnchor)),
            (textInput.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)),
            (textInput.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)),
            (textInput.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16))
        ])
    }
    
    fileprivate func updatePlaceholder() {
        guard let placeholder = textInput.placeholder, let font = self.textInput.font else {
            return
        }
        let color = AppColors.placeholderColor ?? UIColor.lightGray
        #if swift(>=4.2)
        textInput.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font
            ]
        )
        #elseif swift(>=4.0)
        textInput.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font
            ]
        )
        #else
        textInput.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: font]
        )
        #endif
    }
    
    private func setupActionButton() {
        selectionBtn = UIButton(frame: self.bounds)
        selectionBtn.translatesAutoresizingMaskIntoConstraints = false
        selectionBtn.addTarget(self, action: #selector(tapSelectionBtn), for: .touchUpInside)
        selectionBtn.isHidden = true
        self.addSubview(selectionBtn)
        NSLayoutConstraint.activate([
            (selectionBtn.topAnchor.constraint(equalTo: self.topAnchor)),
            (selectionBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor)),
            (selectionBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor)),
            (selectionBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor))
        ])
    }
    
    // MARK: Left View Setup
    private var leftViewButton = UIButton(type: .custom)
    private var leftViewWidth: NSLayoutConstraint?
    private var leftViewDivider = UIView()
    
    @IBInspectable
    open var leftViewMessage: String = "" {
        didSet {
            setupLeftView()
        }
    }
    
    @IBInspectable
    open var leftViewImage: UIImage? = nil {
        didSet {
            setupLeftView()
        }
    }
    
    @IBInspectable
    open var leftColor: UIColor? = nil {
        didSet {
            setupLeftView()
        }
    }
    
    @IBInspectable
    open var showLeftViewDivider: Bool = false {
        didSet {
            setupLeftView()
        }
    }
    
    var leftViewAction: (() -> ())?
    var didPressReturn: (() -> Void)?

    private func setupLeftView() {
        leftViewDivider.removeFromSuperview()
        if leftViewMessage.isBlank && leftViewImage != nil {
            leftViewButton.contentHorizontalAlignment = .center
            leftViewButton.setTitle("", for: .normal)
            leftViewButton.setImage(leftViewImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftViewButton.tintColor = leftColor ?? textColor
            let size: CGFloat = 30
            leftViewButton.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: size, height: size)
            leftViewButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            leftViewButton.addTarget(self, action: #selector(tapLefttView), for: .touchUpInside)
            self.textInput?.leftView = leftViewButton
            self.textInput?.leftViewMode = .always
        } else if !leftViewMessage.isBlank || leftViewImage != nil {
            leftViewWidth?.isActive = false
            leftViewWidth = nil
            leftViewButton.contentHorizontalAlignment = .leading
            leftViewButton.setTitle(leftViewMessage, for: .normal)
            leftViewButton.titleLabel?.font = self.textInput?.font
            leftViewButton.setImage(leftViewImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftViewButton.tintColor = leftColor ?? textColor
            leftViewButton.setTitleColor(leftColor ?? textColor, for: .normal)
            var msgWidth: CGFloat = 0
            let imgWidth: CGFloat = leftViewImage != nil ? 20:0
            if let font = leftViewButton.titleLabel?.font {
                msgWidth = leftViewMessage.widthOfString(usingFont: font)
            }
            let totalWidth = msgWidth + imgWidth
            let dividerValue: CGFloat = showLeftViewDivider ? 10:0
            let verticalInset: CGFloat = 0
            leftViewButton.imageEdgeInsets = UIEdgeInsets(top: verticalInset, left: msgWidth, bottom: -verticalInset, right: -imgWidth/2)
            leftViewButton.titleEdgeInsets = UIEdgeInsets(top: verticalInset, left: -(imgWidth + dividerValue), bottom: -verticalInset, right: 0)
            leftViewButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: dividerValue, bottom: 0, right: dividerValue)
            leftViewButton.frame = CGRect(x: CGFloat(20), y: CGFloat(0), width: totalWidth, height: imgWidth)
            leftViewButton.addTarget(self, action: #selector(tapLefttView), for: .touchUpInside)
            if showLeftViewDivider {
                leftViewDivider.frame = CGRect(x: totalWidth + dividerValue + 8, y: 0, width: 1, height: self.height - 6)
                leftViewDivider.backgroundColor = inActiveColor
                self.textInput.addSubview(leftViewDivider)
            }
            self.textInput?.leftView = leftViewButton
            self.textInput?.leftViewMode = .always
        } else {
            self.textInput?.leftView = nil
            self.textInput?.leftViewMode = .never
        }
    }
    
    @objc private func tapLefttView() {
        leftViewAction?()
    }
    
    private var rightViewButton = UIButton(type: .custom)
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            setupRightView()
        }
    }
    
    @IBInspectable
    open var rightColor: UIColor? = nil {
        didSet {
            setupRightView()
        }
    }
    
    // MARK: Right View Setup
    var rightViewAction: (() -> ())?
    
    func setupRightView() {
        if let image = rightImage {
            let rView = UIButton()
            rView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            rView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            if let color = rightColor {
                rView.tintColor = color
                rView.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                rView.setImage(image, for: .normal)
            }
            rView.addTarget(self, action: #selector(tapRightView), for: .touchUpInside)
            textInput?.rightView = rView
            textInput?.rightViewMode = .always
        } else {
            self.textInput?.rightView = nil
            self.textInput?.rightViewMode = .never
        }
    }
    
    @objc private func tapRightView() {
        rightViewAction?()
    }
    
    @IBInspectable var isEnable: Bool = true {
        didSet {
            manageEnableHandling()
        }
    }
    
    @IBInspectable var isSelectable: Bool = false {
        didSet {
            manageEnableHandling()
        }
    }
    
    func manageEnableHandling() {
        self.selectionBtn.isHidden = true
        if !isEnable {
            self.alpha = 0.5
            self.textInput.isUserInteractionEnabled = false
        } else if isSelectable {
            self.alpha = 1
            self.textInput.isUserInteractionEnabled = false
            self.selectionBtn.isHidden = false
        } else {
            self.alpha = 1
            self.textInput.isUserInteractionEnabled = true
        }
    }
    
    var selectionAction: (() -> ())?
    
    @objc private func tapSelectionBtn() {
        selectionAction?()
    }
    
    var editingChanged: ((String?) -> ())?
    var textFieldDidBeginEditing: (() -> ())?
    var textFieldDidEndEditing: (() -> ())?
    
    @objc private func valueChanged() {
        editingChanged?(self.text)
        managePlaceholder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        containerView.borderColor = activeColor
        containerView.borderWidth = 1
        textFieldDidBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        containerView.borderColor = inActiveColor
        containerView.borderWidth = 0.4
        textFieldDidEndEditing?()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                

        if currentString.length > newString.length {
            return true
        } else {
            if let allowed = acceptType.allowedCharacters {
                let newSet = CharacterSet(charactersIn: string)
                if !allowed.isSuperset(of: newSet) { return false }
            }
            if let max = acceptType.maxLength, newString.length > max {
                return false
            }
            return true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if didPressReturn != nil {
            didPressReturn?()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    func invalidField(){
        containerView.borderColor = UIColor.red
        containerView.borderWidth = 1
    }
    
    func validField(){
        containerView.borderColor = activeColor
        containerView.borderWidth = 1
    }
    
    func setInlinePlaceholder(text: String?) {
        if let text = text, !text.isBlank {
            placeholderLbl.setTitle("  \(text)  ", for: .normal)
        } else {
            placeholderLbl.setTitle("", for: .normal)
        }
    }
    
    func managePlaceholder() {
        if let val = inlinePlaceholder, !val.isBlank {
            self.setInlinePlaceholder(text: val)
            self.placeholderLbl.isHidden = true // false
        } else {
            self.setInlinePlaceholder(text: placeholder)
            self.placeholderLbl.isHidden = true//self.text?.isEmpty ?? true
        }
    }
}
