import SwiftUI

protocol LoginScreenProtocol: StatefulProtocol where State == LoginScreen.State {
    var eventBus: EventBus { get }

    var client: APIProtocol { get }
}

@MainActor
extension LoginScreenProtocol {
    func sendEmail() async {
        await callWhileLoading(failOn: eventBus) {
            let response = try await client.createNewToken(.init(body: .json(.init(identifier: state.identifier))))

            switch response {
            case .ok:
                break
            case .notFound:
                eventBus.send(.failure(title: "Login.Error.NotFound.Title", text: "Login.Error.NotFound.Message"))
            case .badRequest:
                eventBus.send(.failure(title: "Error.BadRequest.Title", text: "Error.BadRequest.Message"))
            case .default:
                eventBus.send(.error(UnknownError()))
            }
        }
    }
}

struct LoginScreen: View, LoginScreenProtocol {
    let namespace: Namespace.ID

    @ObservedObject
    var state: State

    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var client

    @FocusState
    private var focused: Bool

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(
                text: "Login.Submit",
                canSubmit: state.canSubmit,
                isLoading: state.isLoading,
                submit: submit
            )
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

                TextField("Login.Identifier", text: $state.identifier, prompt: Text("Login.Identifier.Prompt"))
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onSubmit(submit)
                    .accessibilityIdentifier("identifier")
                    .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .labelsHidden()
                #endif
            }
            .onAppear { focused = state.identifier.isEmpty }

            #if !os(macOS)
                submitButton
            #endif
        }
        .accessibilityIdentifier(Destination.login.id)
    }

    private func submit() {
        guard state.canSubmit else { return }
        focused = false

        Task {
            await sendEmail()
        }
    }

    final class State: LoadingViewState {
        @Published
        var identifier = ""

        var canSubmit: Bool { 3 ... 254 ~= identifier.count && !isLoading }
    }
}

#Preview {
    NavigationStack {
        @Namespace
        var namespace

        @State
        var state = LoginScreen.State()

        LoginScreen(namespace: namespace, state: state)
    }
}
