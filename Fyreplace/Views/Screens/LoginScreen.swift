import SwiftUI

struct LoginScreen: View, LoginScreenProtocol {
    let namespace: Namespace.ID

    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var client

    @State
    var isLoading = false

    @AppStorage("account.identifier")
    var identifier = ""

    @AppStorage("account.randomCode")
    var randomCode = ""

    @AppStorage("account.isWaitingForRandomCode")
    var isWaitingForRandomCode = false

    @KeychainStorage("connection.token")
    var token

    @FocusState
    private var focused: FocusedField?

    var body: some View {
        let footer = VStack {
            if isWaitingForRandomCode {
                Text("Account.Help.RandomCode")
            }
        }

        DynamicForm {
            Section(
                header: LogoHeader(text: "Login.Header", namespace: namespace),
                footer: footer
            ) {
                EnvironmentPicker(namespace: namespace).disabled(isWaitingForRandomCode)

                TextField("Login.Identifier", text: $identifier, prompt: Text("Login.Identifier.Prompt"))
                    .autocorrectionDisabled()
                    .focused($focused, equals: .identifier)
                    .disabled(isWaitingForRandomCode)
                    .onSubmit(submit)
                    .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .keyboardType(.asciiCapable)
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
                if identifier.isEmpty {
                    focused = .identifier
                }
            }

            Section {
                SubmitOrCancel(
                    namespace: namespace,
                    submitLabel: "Login.Submit",
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
        case identifier
        case randomCode
    }
}

#Preview {
    NavigationStack {
        @Namespace
        var namespace

        LoginScreen(namespace: namespace)
    }
    .environmentObject(EventBus())
}
