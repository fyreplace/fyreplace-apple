import SwiftUI

struct LoginScreen: View {
    let namespace: Namespace.ID

    @ObservedObject
    var viewModel: ViewModel

    @FocusState
    private var focused: Bool

    var body: some View {
        DynamicForm {
            let submitButton = SubmitButton(text: "Login.Submit", canSubmit: viewModel.canSubmit, submit: submit)
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

                TextField("Login.Identifier", text: $viewModel.identifier, prompt: Text("Login.Identifier.Prompt"))
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onSubmit(submit)
                    .accessibilityIdentifier("identifier")
                    .matchedGeometryEffect(id: "first-field", in: namespace)
                #if !os(macOS)
                    .labelsHidden()
                #endif
            }
            .onAppear { focused = viewModel.identifier.isEmpty }

            #if !os(macOS)
                submitButton
            #endif
        }
        .accessibilityIdentifier(Destination.login.id)
    }

    private func submit() {
        guard viewModel.canSubmit else { return }
        focused = false
    }
}

#Preview {
    NavigationStack {
        @Namespace
        var namespace

        @StateObject
        var viewModel = LoginScreen.ViewModel()

        LoginScreen(namespace: namespace, viewModel: viewModel)
    }
}
