import SwiftUI

struct SubmitOrCancel: View {
    let namespace: Namespace.ID
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
        .matchedGeometryEffect(id: "submit", in: namespace)

        let cancel = Button(role: .cancel, action: cancelAction) {
            Text("Cancel").padding(.horizontal)
        }
        .disabled(!canCancel)

        HStack {
            #if os(macOS)
                cancel.controlSize(.large)
                Spacer()
                submit.controlSize(.large)
            #else
                Spacer()
                submit
                    .toolbar {
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