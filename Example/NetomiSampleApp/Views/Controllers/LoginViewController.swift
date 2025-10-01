//
//  LoginViewController.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: NSATextField!
    @IBOutlet weak var passwordTextField: NSATextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: NSAButton!
    @IBOutlet weak var passwordIncorrectLabel: UIButton!
    @IBOutlet weak var emailIncorrectLabel: UIButton!
    @IBOutlet weak var emailIncorrectView: UIStackView!
    @IBOutlet weak var createAccountLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        configureTextFields()
        configureCreateAccountLabel()
        configurePasswordToggle()
    }
    
    private func configureTextFields() {
        emailTextField.textInput.spellCheckingType = .no
        emailTextField.textInput.keyboardType = .emailAddress
        emailTextField.textInput.returnKeyType = .next
        
        emailIncorrectLabel.setAttributedTitle(NSAttributedString(string: " Invalid email format"), for: .normal)
        
        emailIncorrectView.isHidden = true
        passwordIncorrectLabel.isHidden = true
        passwordTextField.textInput.returnKeyType = .done
        
        emailTextField.editingChanged = { [weak self] _ in
            guard let self = self else {return}
            self.validateFields(sender: emailTextField)
        }
        
        passwordTextField.editingChanged = { [weak self] _ in
            guard let self = self else {return}
            self.validateFields(sender: passwordTextField)
        }
        
        emailTextField.textFieldDidBeginEditing = { [weak self] in
            guard let self = self else {return}
            self.emailIncorrectView.isHidden ? self.emailTextField.validField() : self.emailTextField.invalidField()
        }
        
        passwordTextField.textFieldDidBeginEditing = { [weak self] in
            guard let self = self else { return }
            self.passwordIncorrectLabel.isHidden ? self.passwordTextField.validField() : self.passwordTextField.invalidField()
        }
        
        emailTextField.textFieldDidEndEditing = { [weak self] in
            guard let self = self else { return }
            self.emailIncorrectView.isHidden ? () : self.emailTextField.invalidField()
        }
        
        passwordTextField.textFieldDidEndEditing = {[weak self] in
            guard let self = self else {return}
            self.passwordIncorrectLabel.isHidden ? () : self.passwordTextField.invalidField()
        }
        emailTextField.didPressReturn = { [weak self] in
            guard let self = self else { return }
            self.passwordTextField.textInput.becomeFirstResponder()
        }
        setupToolbars()
    }
    
    private func setupToolbars() {
        // attach to the inner UITextFields
        emailTextField.textInput.addDoneToolbar(target: self, action: #selector(dismissKeyboard))
        passwordTextField.textInput.addDoneToolbar(target: self, action: #selector(dismissKeyboard))
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    private func configureCreateAccountLabel() {
        createAccountLabel.numberOfLines = 0
        createAccountLabel.isUserInteractionEnabled = true
        
        let fullText = "Don’t have account? Create account"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Apply attributes
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: AppColors.placeholderColor ?? UIColor.black
        ], range: (fullText as NSString).range(of: "Don’t have account?"))
        
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor.black
        ], range: (fullText as NSString).range(of: "Create account"))
        
        createAccountLabel.attributedText = attributedString
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCreateAccountTap(_:)))
        createAccountLabel.addGestureRecognizer(tapGesture)
    }
    
    private func configurePasswordToggle() {
        passwordTextField.rightImage = AppImages.hidePassword
        passwordTextField.textInput.isSecureTextEntry = true
        
        passwordTextField.rightViewAction = { [weak self] in
            guard let self = self else { return }
            self.passwordTextField.textInput.isSecureTextEntry.toggle()
            self.passwordTextField.rightImage = self.passwordTextField.textInput.isSecureTextEntry ? AppImages.hidePassword : AppImages.showPassword
        }
    }
    
    // MARK: - Validation Methods
    private func validateFields(sender: NSATextField) {
        let isEmailValid = !(emailTextField.text?.isBlank ?? true) && !(emailTextField.text?.checkIfInvalid(.email) ?? true)
        let isPasswordValid = !(passwordTextField.text?.checkIfInvalid(.password) ?? true)
        
        if sender == emailTextField {
            if isEmailValid {
                emailIncorrectView.isHidden = true
                emailTextField.validField()
            }else{
                emailIncorrectView.isHidden = false
                emailTextField.invalidField()
            }
        } else if sender == passwordTextField {
            
            if isPasswordValid {
                passwordIncorrectLabel.isHidden = true
                passwordTextField.validField()
            }else{
                passwordIncorrectLabel.isHidden = false
                passwordTextField.invalidField()
            }
        }
        
        loginButton.isEnable = isEmailValid && isPasswordValid
    }
    
    @objc private func handleCreateAccountTap(_ gesture: UITapGestureRecognizer) {
        let range = (createAccountLabel.text! as NSString).range(of: "Create account")
        
        if gesture.didTapAttributedTextInLabel(label: createAccountLabel, inRange: range) {
            debugPrint("Create Account Tapped")
            navigateToCreateAccount()
        }
    }
    
    // MARK: - Actions
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        debugPrint("Forgot Password Tapped")
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        navigateToHome()
        debugPrint("Login Button Tapped")
    }
    
    // MARK: - Navigation Methods
    private func navigateToCreateAccount() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createAccountVC = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController {
            navigationController?.pushViewController(createAccountVC, animated: true)
        }
    }
    
    private func navigateToHome() {
        Defaults.email = emailTextField.text
        Defaults.name = "Guest User"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
}
