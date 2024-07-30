import SwiftUI

struct RegisterScreen: View {
    let namespace: Namespace.ID

    @ObservedObject
    var viewModel: ViewModel

    @FocusState
    private var focused: FocusedField?

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(text: "Register.Submit", canSubmit: viewModel.canSubmit, submit: submit)
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

                TextField("Register.Username", text: $viewModel.username, prompt: usernamePrompt)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focused = .email }
                    .accessibilityIdentifier("username")
                    .matchedGeometryEffect(id: "first-field", in: namespace)

                TextField("Register.Email", text: $viewModel.email, prompt: emailPrompt)
                    .textContentType(.email)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.done)
                    .onSubmit(submit)
                    .accessibilityIdentifier("email")
            }
            .onAppear {
                if viewModel.username.isEmpty {
                    focused = .username
                } else if viewModel.email.isEmpty {
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
        guard viewModel.canSubmit else { return }
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

        @StateObject
        var viewModel = RegisterScreen.ViewModel()

        RegisterScreen(namespace: namespace, viewModel: viewModel)
    }
}
