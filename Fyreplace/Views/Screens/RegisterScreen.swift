import SwiftUI

struct RegisterScreen: View {
    let namespace: Namespace.ID

    @SceneStorage("LoginScreen.username")
    private var username = ""

    @SceneStorage("LoginScreen.email")
    private var email = ""

    @FocusState
    private var focused: FocusedField?

    private var isUsernameValid: Bool { 3 ... 50 ~= username.count }
    private var isEmailValid: Bool { 3 ... 254 ~= email.count && email.contains("@") }
    private var canSubmit: Bool { isUsernameValid && isEmailValid }

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(text: "Register.Submit", canSubmit: canSubmit, submit: submit)
                .matchedGeometryEffect(id: "submit", in: namespace)

            #if os(macOS)
                let footer = submitButton.padding(.top)
                let usernamePrompt = Text("Register.Username.Prompt")
                let emailPrompt = Text("Register.Email.Prompt")
            #else
                let footer = Text("Register.Help")
                let usernamePrompt: Text? = nil
                let emailPrompt: Text? = nil
            #endif

            Section(
                header: LogoHeader(text: "Register.Header", namespace: namespace),
                footer: footer
            ) {
                EnvironmentPicker(namespace: namespace)

                TextField("Register.Username", text: $username, prompt: usernamePrompt)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focused = .email }
                    .accessibilityIdentifier("username")
                    .matchedGeometryEffect(id: "first-field", in: namespace)

                TextField("Register.Email", text: $email, prompt: emailPrompt)
                    .textContentType(.email)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.done)
                    .onSubmit(submit)
                    .accessibilityIdentifier("email")
            }
            .onAppear {
                if username.isEmpty {
                    focused = .username
                } else if email.isEmpty {
                    focused = .email
                }
            }

            #if !os(macOS)
                submitButton
            #endif
        }
        .accessibilityIdentifier(Destination.register.id)
    }

    private func submit() {
        guard canSubmit else { return }
        focused = nil
    }
}

private enum FocusedField {
    case username
    case email
}

#Preview {
    NavigationStack {
        @Namespace
        var namespace

        RegisterScreen(namespace: namespace)
    }
}
