//
//  CreateButtonTableViewCell.swift
//  NetomiSampleApp
//
//  Created by Netomi on 18/11/24.
//

import UIKit

class CreateButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var createAccountBtn: NSAButton!
    @IBOutlet weak var loginLabel: UILabel!
    
    var loginButtonTapped: (() -> ())?
    var createButtonTapped: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLoginLabel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setButtonEnabled(_ isEnabled: Bool = false){
        createAccountBtn.isEnable = isEnabled
    }
    
    private func configureLoginLabel() {
        loginLabel.numberOfLines = 0
        loginLabel.isUserInteractionEnabled = true
        
        let fullText = "Existing user ? Login"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Apply attributes
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: AppColors.placeholderColor ?? UIColor.black
        ], range: (fullText as NSString).range(of: "Existing user ?"))
        
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor.black
        ], range: (fullText as NSString).range(of: "Login"))
        
        loginLabel.attributedText = attributedString
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLoginTap(_:)))
        loginLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLoginTap(_ gesture: UITapGestureRecognizer) {
        let range = (loginLabel.text! as NSString).range(of: "Login")
        
        if gesture.didTapAttributedTextInLabel(label: loginLabel, inRange: range) {
            debugPrint("Create Account Tapped")
            loginButtonTapped?()
        }
    }
    
    @IBAction func createAccountBtnTap(){
        createButtonTapped?()
    }
    
}
