import SwiftUI

struct DynamicList<Content>: View where Content: View {
    @ViewBuilder
    let content: () -> Content

    var body: some View {
        #if os(macOS)
            DynamicForm {
                List {
                    content()
                }
            }
        #else
            List {
                content()
            }
        #endif
    }
}
