import SwiftUI

struct LoginScreen: View {
    let namespace: Namespace.ID

    @SceneStorage("LoginScreen.identifier")
    private var identifier = ""

    @FocusState
    private var focused: Bool

    private var isIdentifierValid: Bool { 3 ... 254 ~= identifier.count }

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(text: "Login.Submit", canSubmit: isIdentifierValid, submit: submit)
                .matchedGeometryEffect(id: "submit", in: namespace)

            #if os(macOS)
                let footer = submitButton.padding(.top)
            #else
                let footer: Spacer? = nil
            #endif

            Section(
                header: LogoHeader(text: "Login.Header", namespace: namespace),
                footer: footer
            ) {
                EnvironmentPicker(namespace: namespace)

                TextField("Login.Identifier", text: $identifier, prompt: Text("Login.Identifier.Prompt"))
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onSubmit(submit)
                    .accessibilityIdentifier("identifier")
                    .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .labelsHidden()
                #endif
            }
            .onAppear { focused = identifier.isEmpty }

            #if !os(macOS)
                submitButton
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
        @Namespace
        var namespace

        LoginScreen(namespace: namespace)
    }
}
