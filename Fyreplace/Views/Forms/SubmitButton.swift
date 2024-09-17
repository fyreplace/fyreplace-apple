import SwiftUI

struct SubmitButton: View {
    let text: LocalizedStringKey
    let isLoading: Bool
    let action: () -> Void

    @Namespace
    private var namespace

    @Environment(\.isEnabled)
    private var isEnabled

    var body: some View {
        let button = Button(action: action) {
            Text(text)
                #if os(macOS)
                    .padding(.horizontal)
                    .opacity(isLoading ? 0 : 1)
                    .overlay {
                        if isLoading {
                            ProgressView().controlSize(.small)
                        }
                    }
                #endif
        }
        .animation(.default, value: isEnabled)
        .matchedGeometryEffect(id: "button", in: namespace)

        #if os(macOS)
            if isEnabled {
                button.buttonStyle(.borderedProminent)
            } else {
                button
            }
        #else
            if isLoading {
                ProgressView().controlSize(.regular)
            } else {
                button
            }
        #endif
    }
}
