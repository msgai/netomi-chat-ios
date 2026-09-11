//
//  NetomiSwiftUISampleAppApp.swift
//  NetomiSwiftUISampleApp
//

import SwiftUI
import Netomi

@main
struct NetomiSwiftUISampleAppApp: App {

    init() {
        /// Initialize the Netomi SDK once, as early as possible in the app's lifecycle.
        /// Contact Netomi support to get your botRefId and select the correct environment
        /// (.USProd / .INProd / .EUProd).
        NetomiChat.shared.initialize(
            botRefId: "your-bot-ref-id", // <-- Replace this with your actual botRefId
            env: .USProd
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
