//
//  ContentView.swift
//  NetomiSwiftUISampleApp
//

import SwiftUI
import Netomi

struct ContentView: View {

    @State private var errorMessage: String?
    @State private var isShowingError = false

    var body: some View {
        ZStack {
            Image(.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Text("Netomi Chat AI")
                        .font(.title.bold())
                        .foregroundStyle(Color.placeholder.opacity(0.6))

                    Image(.chatBot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 235, height: 358)
                }

                Spacer()
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    chatFab
                        .padding(.trailing, 28)
                        .padding(.bottom, 48)
                }
            }
        }
        .alert("Unable to Launch Chat", isPresented: $isShowingError, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    /// Floating action button that launches the Netomi chat window.
    /// `NetomiChat.shared` presents its own UI directly on the key window,
    /// so no SwiftUI navigation or sheet is needed here.
    private var chatFab: some View {
        Button(action: launchChat) {
            HStack(spacing: 8) {
                Image(.messageIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                Text("Chat Us")
                    .font(.headline)
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.startYellow, Color.endYellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
        }
    }

    private func launchChat() {
        let jwtToken: String? = nil // Replace with an actual JWT token if your bot requires authentication.

        NetomiChat.shared.launch(jwt: jwtToken) { error in
            errorMessage = error.statusMessage ?? "Status code \(error.statusCode ?? -1)"
            isShowingError = true
        }
    }
}

#Preview {
    ContentView()
}
