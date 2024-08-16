import SwiftUI

struct AuthenticatingScreen<Content>: View where Content: View {
    @ViewBuilder
    let content: () -> Content

    @SceneStorage("RstrictedScreen.choice")
    private var choice = Destination.login

    @AppStorage("account.isWaitingForRandomCode")
    private var isWaitingForRandomCode = false

    @KeychainStorage("connection.token")
    private var token

    var body: some View {
        if token.isEmpty {
            MultiChoiceScreen(
                choices: [.login, .register],
                choice: $choice,
                canChoose: !isWaitingForRandomCode
            )
            .navigationTitle("")
            #if os(macOS)
                .animation(.snappy, value: choice)
            #endif
        } else {
            content()
        }
    }
}
