//
//  CreateAccountViewController.swift
//  NetomiSampleApp
//
//  Created by Netomi on 18/11/24.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var formFields: [FloatingTextFieldItem] = []
    
    private enum CellIdentifiers {
        static let headerCell = "HeaderTableViewCell"
        static let textFieldCell = "TextFieldTableViewCell"
        static let createButtonCell = "CreateButtonTableViewCell"
    }
    
    private var isButtonEnabled = false {
        didSet {
            updateButtonState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        tableView.keyboardDismissMode = .interactive
        // Do any additional setup after loading the view.
    }
    private func setupUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Register UITableViewCells
        tableView.register(UINib(nibName: CellIdentifiers.textFieldCell, bundle: nil), forCellReuseIdentifier: CellIdentifiers.textFieldCell)
        tableView.register(UINib(nibName: CellIdentifiers.headerCell, bundle: nil), forCellReuseIdentifier: CellIdentifiers.headerCell)
        tableView.register(UINib(nibName: CellIdentifiers.createButtonCell, bundle: nil), forCellReuseIdentifier: CellIdentifiers.createButtonCell)
        
        // Set delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Setup form fields
        formFields.append(FloatingTextFieldItem(title: "Email", placeholder: "Enter your email", text: "", isEnable: true, leftImage: AppImages.email,key: "email" ,errorMsg: " Invalid email format"))
        formFields.append(FloatingTextFieldItem(title: "Name", placeholder: "Enter your name", text: "", isEnable: true, leftImage: AppImages.name,key: "name", errorMsg: " Enter your name"))
        formFields.append(FloatingTextFieldItem(title: "Mobile Number", placeholder: "Enter your number", text: "", isEnable: true, leftImage: AppImages.number,key: "number" ,acceptType: .phone, errorMsg: " Invalid phone format"))
        formFields.append(FloatingTextFieldItem(title: "Password", placeholder: "Enter your password", text: "", isEnable: true, leftImage: AppImages.password, rightImage: AppImages.hidePassword,key: "password" ,errorMsg: " Enter valid password"))
    }
    
    private func validateField(_ field: FloatingTextFieldItem, text: String?) -> Bool {
        switch field.key {
        case "name":
            return (text?.count ?? 0) > 2
        case "email":
            return text?.checkIfInvalid(.email) == false
        case "password":
            return text?.checkIfInvalid(.password) == false
        default:
            return true
        }
    }
    
    private func checkAllFieldsValid() -> Bool {
        return formFields.allSatisfy { validateField($0, text: $0.text) }
    }
    
    private func updateButtonState() {
        if let cell = tableView.cellForRow(at: IndexPath(row: formFields.count + 1, section: 0)) as? CreateButtonTableViewCell {
            cell.setButtonEnabled(isButtonEnabled)
        }
    }
    
    private func navigateToHome() {
        Defaults.email = formFields[0].text
        Defaults.name = formFields[1].text
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboardChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboardChange(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func handleKeyboardChange(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let keyboardFrameScreen = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        else { return }

        // Convert to this view’s coordinate space
        let kbFrame = view.convert(keyboardFrameScreen, from: view.window)
        let intersects = view.bounds.intersects(kbFrame)

        var inset = tableView.contentInset
        var indicatorInset = tableView.scrollIndicatorInsets
        let bottomSafe = view.safeAreaInsets.bottom

        if intersects {
            let overlap = max(0, view.bounds.maxY - kbFrame.minY)
            inset.bottom = overlap - bottomSafe
            indicatorInset.bottom = inset.bottom
        } else {
            inset.bottom = 0
            indicatorInset.bottom = 0
        }

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = indicatorInset
            self.scrollActiveFieldIntoView()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func scrollActiveFieldIntoView() {
        guard let first = self.view.currentFirstResponder as? UIView else { return }
        let rect = tableView.convert(first.bounds, from: first)
        tableView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: true)
    }

}

extension CreateAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formFields.count + 2 // Additional rows for header and create button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            // Header cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.headerCell, for: indexPath) as? HeaderTableViewCell else {
                return UITableViewCell()
            }
            return cell
            
        case formFields.count + 1:
            // Create Button cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.createButtonCell, for: indexPath) as? CreateButtonTableViewCell else {
                return UITableViewCell()
            }
            
            cell.loginButtonTapped = {[weak self] in
                guard let self = self else {return}
                self.navigationController?.popViewController(animated: true)
            }
            
            cell.createButtonTapped = {[weak self] in
                guard let self = self else {return}
                self.navigateToHome()
            }
            
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.textFieldCell, for: indexPath) as? TextFieldTableViewCell else {
                return UITableViewCell()
            }
            
            let field = formFields[indexPath.row - 1]
            cell.configure = field
            
            cell.editingChanged = { [weak self] in
                guard let self = self else { return }
                
                let isValid = self.validateField(field, text: field.text)
                cell.errorMsgView.isHidden = isValid
                isValid ? cell.validField() : cell.invalidFiled()
                self.isButtonEnabled = self.checkAllFieldsValid()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return cell
        }
    }
}
