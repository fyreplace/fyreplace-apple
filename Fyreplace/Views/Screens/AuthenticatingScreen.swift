import SwiftUI

struct AuthenticatingScreen<Content>: View where Content: View {
    @ViewBuilder
    let content: () -> Content

    @AppStorage("account.isWaitingForRandomCode")
    private var isWaitingForRandomCode = false

    @KeychainStorage("connection.token")
    private var token

    @State
    private var choice: Destination

    init(isRegistering: Bool, content: @escaping () -> Content) {
        self.content = content
        choice = isRegistering ? .register : .login
    }

    var body: some View {
        if token.isEmpty {
            MultiChoiceScreen(
                choices: [.login, .register],
                choice: $choice,
                canChoose: !isWaitingForRandomCode
            )
            .navigationTitle("")
            .handlesExternalEvents(preferring: ["*"], allowing: ["action=connect"])
            #if os(macOS)
                .animation(.snappy, value: choice)
            #endif
        } else {
            content()
        }
    }
}
