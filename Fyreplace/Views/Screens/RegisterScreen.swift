import SwiftUI

struct RegisterScreen: View, RegisterScreenProtocol {
    let namespace: Namespace.ID

    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var api

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

        DynamicForm {
            Section {
                EnvironmentPicker(namespace: namespace).disabled(isWaitingForRandomCode)

                TextField(
                    "Register.Username",
                    text: $username,
                    prompt: usernamePrompt
                )
                .textContentType(.username)
                .autocorrectionDisabled()
                .focused($focused, equals: .username)
                .disabled(isWaitingForRandomCode)
                .submitLabel(.next)
                .onSubmit { focused = .email }
                .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                #endif

                TextField(
                    "Register.Email",
                    text: $email,
                    prompt: emailPrompt
                )
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
                    TextField(
                        "Account.RandomCode",
                        text: $randomCode,
                        prompt: Text("Account.RandomCode.Prompt")
                    )
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

                SubmitOrCancel(
                    namespace: namespace,
                    submitLabel: "Register.Submit",
                    canSubmit: canSubmit,
                    canCancel: isWaitingForRandomCode,
                    isLoading: isLoading,
                    submitAction: submit,
                    cancelAction: cancel
                )
            } header: {
                LogoHeader(namespace: namespace) {
                    Image("Logo", label: Text("Logo")).resizable()
                } textContent: {
                    Text("Register.Header")
                }
            } footer: {
                VStack {
                    if isWaitingForRandomCode {
                        Text("Account.Help.RandomCode")
                    } else {
                        firstStepFooter
                    }
                }
            }
            .onAppear {
                if username.isEmpty {
                    focused = .username
                } else if email.isEmpty {
                    focused = .email
                }
            }
        }
        .disabled(isLoading)
        .animation(.default, value: isWaitingForRandomCode)
        .onReceive(
            eventBus.events
                .filter { _ in isWaitingForRandomCode }
                .compactMap { $0 as? RandomCodeEvent }
        ) {
            randomCode = $0.randomCode
            submit()
        }
    }

    private func submit() {
        guard canSubmit else { return }
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

@available(macOS 14.0, *)
@available(iOS 17.0, *)
#Preview {
    @Previewable
    @Namespace
    var namespace

    NavigationStack {
        RegisterScreen(namespace: namespace)
    }
    .environmentObject(EventBus())
}
