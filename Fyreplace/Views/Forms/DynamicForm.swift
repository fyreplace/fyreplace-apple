import SwiftUI

struct DynamicForm<Content>: View where Content: View {
    @ViewBuilder
    let content: () -> Content

    var body: some View {
        #if os(macOS)
            Form {
                content()
            }
            .formStyle(.grouped)
            .frame(minWidth: 360, maxWidth: 600)
            .fixedSize()
            .padding()
        #else
            HStack {
                Form {
                    content()
                }
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : nil)
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
        #endif
    }
}
