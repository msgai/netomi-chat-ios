//
//  HomeViewController.swift
//  NetomiSampleApp
//

import UIKit
import Netomi

/// The example app's single screen, built entirely in code (no storyboard).
/// Mirrors the layout of the SwiftUI example's `ContentView` for a consistent
/// look across both sample apps.
class HomeViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Netomi Chat AI"
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textColor = UIColor(white: 0.667, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chatBotImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chatBot"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BG"))
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var chatButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(
            "Chat Us",
            attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 17, weight: .semibold)])
        )
        config.image = UIImage(named: "messageIcon")?.resized(to: CGSize(width: 24, height: 24))
        config.imagePadding = 8
        config.baseForegroundColor = .black
        config.baseBackgroundColor = UIColor(named: "startYellow")
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapChatBtn), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        setupBot()
    }

    /// Groups the title and chatBot image so they can be centered together as a unit.
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 48
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Layout

    private func setupLayout() {
        view.backgroundColor = .systemBackground

        view.addSubview(backgroundImageView)
        view.addSubview(contentStack)
        view.addSubview(chatButton)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(chatBotImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            chatBotImageView.widthAnchor.constraint(equalToConstant: 235),
            chatBotImageView.heightAnchor.constraint(equalToConstant: 358),

            chatButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            chatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
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

    // MARK: - Launch Chat SDK

    /// Launches the Netomi chat window using optional JWT
    @objc private func tapChatBtn() {
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
        config.navigationIcon = UIImage(named: "messageIcon")
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

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
