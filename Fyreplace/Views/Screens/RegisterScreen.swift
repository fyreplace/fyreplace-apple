import SwiftUI

struct RegisterScreen: View, RegisterScreenProtocol {
    let namespace: Namespace.ID

    @State
    var isLoading = false

    @AppStorage("account.username")
    var username = ""

    @AppStorage("account.email")
    var email = ""

    @FocusState
    private var focused: FocusedField?

    var body: some View {
        let submitButton = SubmitButton(
            text: "Register.Submit",
            isLoading: isLoading,
            submit: submit
        )
        .disabled(!canSubmit)
        .matchedGeometryEffect(id: "submit", in: namespace)

        #if os(macOS)
            let footer: Spacer? = nil
            let usernamePrompt = Text("Register.Username.Prompt")
            let emailPrompt = Text("Register.Email.Prompt")
        #else
            let footer = Text("Register.Help")
            let usernamePrompt: Text? = nil
            let emailPrompt: Text? = nil
        #endif

        DynamicForm {
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
                    .matchedGeometryEffect(id: "first-field", in: namespace)

                TextField("Register.Email", text: $email, prompt: emailPrompt)
                    .textContentType(.email)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.done)
                    .onSubmit(submit)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                #endif
            }
            .onAppear {
                if username.isEmpty {
                    focused = .username
                } else if email.isEmpty {
                    focused = .email
                }
            }

            Section {
                HStack {
                    #if os(macOS)
                        Spacer()
                        submitButton.controlSize(.large)
                    #else
                        Spacer()
                        submitButton
                        Spacer()
                    #endif
                }
            }
        }
    }

    private func submit() {
        guard canSubmit else { return }
        focused = nil
    }

    enum FocusedField {
        case username
        case email
    }
}

#Preview {
    NavigationStack {
        @Namespace
        var namespace

        RegisterScreen(namespace: namespace)
    }
    .environmentObject(EventBus())
}
