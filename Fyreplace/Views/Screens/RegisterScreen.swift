import SwiftUI

struct RegisterScreen: View, RegisterScreenProtocol {
    let namespace: Namespace.ID

    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var client

    @State
    var isLoading = false

    @AppStorage("account.username")
    var username = ""

    @AppStorage("account.email")
    var email = ""

    @AppStorage("account.randomCode")
    var randomCode = ""

    @AppStorage("account.isWaitingForRandomCode")
    var isWaitingForRandomCode = false

    @AppStorage("account.isRegistering")
    var isRegistering = false

    @KeychainStorage("connection.token")
    var token

    @FocusState
    private var focused: FocusedField?

    var body: some View {
        #if os(macOS)
            let firstStepFooter: Text? = nil
            let usernamePrompt = Text("Register.Username.Prompt")
            let emailPrompt = Text("Register.Email.Prompt")
        #else
            let firstStepFooter = Text("Register.Help")
            let usernamePrompt: Text? = nil
            let emailPrompt: Text? = nil
        #endif

        let footer = VStack {
            if isWaitingForRandomCode {
                Text("Account.Help.RandomCode")
            } else {
                firstStepFooter
            }
        }

        DynamicForm {
            Section(
                header: LogoHeader(text: "Register.Header", namespace: namespace),
                footer: footer
            ) {
                EnvironmentPicker(namespace: namespace).disabled(isWaitingForRandomCode)

                TextField("Register.Username", text: $username, prompt: usernamePrompt)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .username)
                    .disabled(isWaitingForRandomCode)
                    .submitLabel(.next)
                    .onSubmit { focused = .email }
                    .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .keyboardType(.asciiCapable)
                #endif

                TextField("Register.Email", text: $email, prompt: emailPrompt)
                    .textContentType(.email)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .disabled(isWaitingForRandomCode)
                    .submitLabel(.done)
                    .onSubmit(submit)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                #endif

                if isWaitingForRandomCode {
                    TextField("Account.RandomCode", text: $randomCode, prompt: Text("Account.RandomCode.Prompt"))
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled()
                        .focused($focused, equals: .randomCode)
                        .onSubmit(submit)
                        .onAppear {
                            if randomCode.isEmpty {
                                focused = .randomCode
                            }
                        }
                    #if !os(macOS)
                        .keyboardType(.asciiCapable)
                    #endif
                }
            }
            .onAppear {
                if username.isEmpty {
                    focused = .username
                } else if email.isEmpty {
                    focused = .email
                }
            }

            Section {
                SubmitOrCancel(
                    namespace: namespace,
                    submitLabel: "Register.Submit",
                    canSubmit: canSubmit,
                    canCancel: isWaitingForRandomCode,
                    isLoading: isLoading,
                    submitAction: submit,
                    cancelAction: cancel
                )
            }
        }
        .disabled(isLoading)
        .animation(.default, value: isWaitingForRandomCode)
    }

    private func submit() {
        focused = nil

        Task {
            await submit()
        }
    }

    enum FocusedField {
        case username
        case email
        case randomCode
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
