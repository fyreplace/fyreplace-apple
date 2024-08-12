import SwiftUI

protocol RegisterScreenProtocol: StatefulProtocol where State == RegisterScreen.State {}

struct RegisterScreen: View, RegisterScreenProtocol {
    let namespace: Namespace.ID

    @ObservedObject
    var state: State

    @FocusState
    private var focused: FocusedField?

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(
                text: "Register.Submit",
                canSubmit: state.canSubmit,
                isLoading: state.isLoading,
                submit: submit
            )
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

                TextField("Register.Username", text: $state.username, prompt: usernamePrompt)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focused = .email }
                    .accessibilityIdentifier("username")
                    .matchedGeometryEffect(id: "first-field", in: namespace)

                TextField("Register.Email", text: $state.email, prompt: emailPrompt)
                    .textContentType(.email)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.done)
                    .onSubmit(submit)
                    .accessibilityIdentifier("email")
            }
            .onAppear {
                if state.username.isEmpty {
                    focused = .username
                } else if state.email.isEmpty {
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
        guard state.canSubmit else { return }
        focused = nil
    }

    final class State: LoadingViewState {
        @Published
        var username = ""

        @Published
        var email = ""

        var isUsernameValid: Bool { 3 ... 50 ~= username.count }
        var isEmailValid: Bool { 3 ... 254 ~= email.count && email.contains("@") }
        var canSubmit: Bool { isUsernameValid && isEmailValid && !isLoading }
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

        @StateObject
        var state = RegisterScreen.State()

        RegisterScreen(namespace: namespace, state: state)
    }
}
