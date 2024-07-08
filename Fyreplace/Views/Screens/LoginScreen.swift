import SwiftUI

struct LoginScreen: View {
    @SceneStorage("LoginScreen.identifier")
    private var identifier = ""

    @Namespace
    private var mainNamespace

    @FocusState
    private var focused: Bool

    private var isIdentifierValid: Bool { 3 ... 254 ~= identifier.count }

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(text: "Login.Submit", canSubmit: isIdentifierValid, submit: submit)

            #if os(macOS)
                let footer = submitButton.padding(.top)
            #else
                let footer: Spacer? = nil
            #endif

            Section(header: LogoHeader(text: "Login.Header"), footer: footer) {
                TextField("Login.Identifier", text: $identifier, prompt: Text("Login.Identifier.Prompt"))
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onSubmit(submit)
                    .accessibilityIdentifier("identifier")
                #if os(macOS)
                    .prefersDefaultFocus(in: mainNamespace)
                #else
                    .labelsHidden()
                #endif
            }

            #if !os(macOS)
                Section {
                    submitButton
                }
            #endif
        }
        .accessibilityIdentifier(Destination.login.id)
    }

    private func submit() {
        guard isIdentifierValid else { return }
        focused = false
    }
}

#Preview {
    NavigationStack {
        LoginScreen()
    }
}
