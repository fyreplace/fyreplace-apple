import SwiftUI

struct MainView: View {
    var body: some View {
        #if os(macOS)
            RegularNavigation()
        #else
            DynamicNavigation()
        #endif
    }
}

#Preview {
    MainView()
}
