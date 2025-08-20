import SwiftUI

struct SubmitOrCancel: View {
    let submitLabel: LocalizedStringKey
    let canSubmit: Bool
    let canCancel: Bool
    let isLoading: Bool
    let submitAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        let submit = SubmitButton(
            text: submitLabel,
            isLoading: isLoading,
            action: submitAction
        )
        .disabled(!canSubmit)

        let cancel = Button(role: .cancel, action: cancelAction) {
            Text("Cancel").padding(.horizontal)
        }
        .disabled(!canCancel)

        HStack {
            #if os(macOS)
                cancel
                Spacer()
                submit
            #else
                Spacer()
                submit.toolbar {
                    if canCancel {
                        ToolbarItem {
                            cancel
                        }
                    }
                }
                Spacer()
            #endif
        }
    }
}
