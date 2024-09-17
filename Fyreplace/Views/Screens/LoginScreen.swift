import SwiftUI

struct LoginScreen: View, LoginScreenProtocol {
    let namespace: Namespace.ID

    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var api

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
        DynamicForm {
            Section {
                EnvironmentPicker(namespace: namespace).disabled(isWaitingForRandomCode)

                TextField(
                    "Login.Identifier",
                    text: $identifier,
                    prompt: Text("Login.Identifier.Prompt")
                )
                .autocorrectionDisabled()
                .focused($focused, equals: .identifier)
                .disabled(isWaitingForRandomCode)
                .onSubmit(submit)
                .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
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
                    submitLabel: "Login.Submit",
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
                    Text("Login.Header")
                }
            } footer: {
                VStack {
                    if isWaitingForRandomCode {
                        Text("Account.Help.RandomCode")
                    }
                }
            }
            .onAppear {
                if identifier.isEmpty {
                    focused = .identifier
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
        case identifier
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
        LoginScreen(namespace: namespace)
    }
    .environmentObject(EventBus())
}
