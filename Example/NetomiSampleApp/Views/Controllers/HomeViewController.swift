//
//  HomeViewController.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit
import Netomi

class HomeViewController: UIViewController {
    
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var drawerNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var drawerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var selectedBotNameLbl: UILabel!
    @IBOutlet weak var chatImg: UIImageView!
    @IBOutlet weak var chatBtn: UIButton!
    
    private var isDrawerOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupInitialState()
        setupBot()
    }
    
    // MARK: - Initial Setup
    
    /// Setup initial UI state and gestures
    private func setupInitialState() {
        nameLbl.text = Defaults.name
        drawerNameLbl.text = Defaults.name
        drawerLeadingConstraint.constant = -300
        overlayView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeDrawer))
        tapGesture.delegate = self
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    /// Initialize the Netomi SDK with the bot reference ID and environment
    private func setupBot() {
        /// Initialize the Netomi SDK with your botRefId and environment.
        /// Contact Netomi support to get your botRefId and select the correct environment (.USProd / .INProd / .EUProd)
        let botRefId = "your-bot-ref-id" // <-- Replace this with your actual botRefId
        let env: NCWEnvironment = .USProd
        NetomiChat.shared.initialize(botRefId: botRefId, env: env)
        
        /// By default, most UI customizations (colors, layout, branding) can be configured via the Netomi Web Dashboard.
        /// If you want to override them manually — for example, to apply themes dynamically — call `applyChatUIConfigurations()` below.
        /// This is optional and can be used for testing or live theme switching.
        
        // Uncomment to apply sample custom UI
        // applyChatUIConfigurations()
    }
    
    
    
    // MARK: - Drawer Toggle Actions
    @IBAction func toggleDrawer(_ sender: UIButton) {
        if isDrawerOpen {
            closeDrawer()
        } else {
            openDrawer()
        }
    }
    
    /// Opens the side drawer with animation
    @objc private func openDrawer() {
        isDrawerOpen = true
        overlayView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.drawerLeadingConstraint.constant = 0
            self.overlayView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    /// Closes the side drawer with animation
    @objc private func closeDrawer() {
        isDrawerOpen = false
        
        // Animate drawer closing
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.drawerLeadingConstraint.constant = -300
            self.overlayView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.overlayView.isHidden = true
        })
    }
    
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        closeDrawer()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        Defaults.removeUnPreservedData()
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.view.window?.rootViewController = navigationController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - Launch Chat SDK
    
    /// Launches the Netomi chat window using optional JWT
    @IBAction func tapChatBtn(_ sender: Any) {
        let jwtToken: String? = nil // Replace with actual JWT token if needed
        
        NetomiChat.shared.launch(jwt: jwtToken, errorHandler: { [weak self] error in
            self?.showAlert(title: "Status Code \(error.statusCode ?? -1)", message: error.statusMessage ?? "")
        })
        
        // Alternative: Launch with specific search query
        /*
         let searchQuery: String = "Your search query"
         NetomiChat.shared.launchWithQuery(searchQuery, jwt: jwtToken, errorHandler: { [weak self] error in
         self?.showAlert(title: "Status Code \(error.statusCode ?? -1)", message: error.statusMessage ?? "")
         })
         */
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension HomeViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view, touchedView.isDescendant(of: drawerView) {
            return false
        }
        return true
    }
    
}

// MARK: - Alert
extension HomeViewController {
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: { _ in
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Netomi SDK Configuration

/// Below extension contains the Netomi SDK's functions that are intended to modify/set the interface & properties. Also, it should be called before "launch" or "launchWithQuery" functions.
extension HomeViewController {
    
    /// Apply default UI configurations to demonstrate customization capabilities
    func applyChatUIConfigurations() {
        updateHeaderConfiguration()
        updateFooterConfiguration()
        updateBotConfiguration()
        updateUserConfiguration()
        updateBubbleConfiguration()
        updateChatWindowConfiguration()
        updateOtherConfiguration()
    }
    
    
    /// Example: Send a single custom parameter to the bot (e.g., user role)
    func sendCustomParameter() {
        NetomiChat.shared.sendCustomParameter(name: "user_role", value: "premium_user")
    }
    
    /// Set multiple custom parameters for the session (e.g., user profile data)
    func setCustomParameter() {
        let userAttributes: [String: String] = [
            "user_id": "12345",
            "user_name": "John Doe",
            "membership_level": "gold",
            "app_version": "7.2.0"
        ]
        NetomiChat.shared.setCustomParameter(userAttributes)
    }
    
    
    /// Set headers for API calls made by the SDK (e.g., auth, tracking, and user segmentation)
    func updateApiHeaderConfiguration() {
        let customHeaders: [String: String] = [
            "X-App-Version": "7.2.0",                                 // Current app version
            "X-Device-ID": "device-98765",                            // Unique device identifier
            "X-Platform": "iOS",                                      // Platform info
            "X-User-Type": "beta_tester",                             // User group or role
            "X-Experiment-Variant": "A",                              // A/B testing group
            "X-Locale": Locale.current.identifier,                    // e.g., "en_US"
        ]
        NetomiChat.shared.updateApiHeaderConfiguration(headers: customHeaders)
    }
    
    
    /// Set the Push token for push notification support
    func setPushToken() {
        let token = "" // Replace with Push token
        NetomiChat.shared.setPushToken(token)
    }
    
    /// Customize the chat header
    func updateHeaderConfiguration() {
        var config: NCWHeaderConfiguration = NCWHeaderConfiguration()
        config.backgroundColor = .red
        config.isGradientApplied = true
        config.isBackPressPopupEnabled = true
        config.navigationIcon = UIImage.logo
        NetomiChat.shared.updateHeaderConfiguration(config: config)
    }
    
    /// Customize the chat footer
    func updateFooterConfiguration() {
        var config: NCWFooterConfiguration = NCWFooterConfiguration()
        config.backgroundColor = .red
        config.inputBoxTextColor = .black
        config.isFooterHidden = false
        config.isNetomiBrandingEnabled = true
        NetomiChat.shared.updateFooterConfiguration(config: config)
    }
    
    /// Customize the bot message UI
    func updateBotConfiguration() {
        var config: NCWBotConfiguration = NCWBotConfiguration()
        config.backgroundColor = .lightGray
        config.isFeedbackEnabled = true
        config.quickReplyBackgroundColor = .lightGray
        config.textColor = .black
        NetomiChat.shared.updateBotConfiguration(config: config)
    }
    
    /// Customize the user message UI
    func updateUserConfiguration() {
        var config: NCWUserConfiguration = NCWUserConfiguration()
        config.backgroundColor = .darkGray
        config.retryColor = .red
        config.textColor = .white
        NetomiChat.shared.updateUserConfiguration(config: config)
    }
    
    /// Customize chat bubbles
    func updateBubbleConfiguration() {
        var config: NCWBubbleConfiguration = NCWBubbleConfiguration()
        config.borderRadius = 20
        config.timeStampColor = .gray
        NetomiChat.shared.updateBubbleConfiguration(config: config)
    }
    
    /// Customize the overall chat window
    func updateChatWindowConfiguration() {
        var config: NCWChatWindowConfiguration = NCWChatWindowConfiguration()
        config.chatWindowBackgroundColor = .white
        NetomiChat.shared.updateChatWindowConfiguration(config: config)
    }
    
    /// Miscellaneous settings for title and description
    func updateOtherConfiguration() {
        var config: NCWOtherConfiguration = NCWOtherConfiguration()
        config.backgroundColor = .white
        config.titleColor = .black
        config.descriptionColor = .black
        NetomiChat.shared.updateOtherConfiguration(config: config)
    }
}
