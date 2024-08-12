import SwiftUI

struct SubmitButton: View {
    let text: LocalizedStringKey
    let canSubmit: Bool
    let isLoading: Bool
    let submit: () -> Void

    var body: some View {
        HStack {
            Spacer()

            let button = Button(action: submit) {
                Text(text).padding(.horizontal)
            }
            .disabled(!canSubmit)
            .animation(.default, value: canSubmit)
            .controlSize(.large)
            .accessibilityIdentifier("submit")

            #if os(macOS)
                if canSubmit {
                    button.buttonStyle(.borderedProminent)
                } else {
                    button
                }
            #else
                if isLoading {
                    ProgressView()
                } else {
                    button
                }
            #endif

            Spacer()
        }
    }
}
