import SwiftUI

struct SubmitButton: View {
    let text: LocalizedStringKey
    let canSubmit: Bool
    let submit: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: submit) {
                Text(text).padding(.horizontal)
            }
            .disabled(!canSubmit)
            .animation(.default, value: canSubmit)
            .controlSize(.large)
            .accessibilityIdentifier("submit")
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            #endif
            Spacer()
        }
    }
}
