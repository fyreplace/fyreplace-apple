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
        let submitButton = SubmitButton(
            text: "Login.Submit",
            isLoading: isLoading,
            submit: submit
        )
        .disabled(!canSubmit)
        .matchedGeometryEffect(id: "submit", in: namespace)

        let cancelButton = Button(role: .cancel, action: cancel) {
            Text("Cancel").padding(.horizontal)
        }
        .disabled(!isWaitingForRandomCode)

        let footer = isWaitingForRandomCode
            ? VStack {
                if isWaitingForRandomCode {
                    Text("Login.Help.RandomCode")
                }
            }
            : nil

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
                    TextField("Login.RandomCode", text: $randomCode, prompt: Text("Login.RandomCode.Prompt"))
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
                HStack {
                    #if os(macOS)
                        cancelButton.controlSize(.large)
                        Spacer()
                        submitButton.controlSize(.large)
                    #else
                        Spacer()
                        submitButton
                            .toolbar {
                                if isWaitingForRandomCode {
                                    ToolbarItem {
                                        cancelButton
                                    }
                                }
                            }
                        Spacer()
                    #endif
                }
            }
        }
        .disabled(isLoading)
    }

    private func submit() {
        guard canSubmit else { return }
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
