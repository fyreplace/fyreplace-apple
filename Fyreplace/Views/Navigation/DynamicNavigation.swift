import SwiftUI

@available(macOS, unavailable)
struct DynamicNavigation: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Environment(\.verticalSizeClass)
    private var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let largeEnough = geometry.size.width > geometry.size.height
                && horizontalSizeClass != .compact
                && verticalSizeClass != .compact

            if largeEnough {
                RegularNavigation()
            } else {
                CompactNavigation()
            }
        }
    }
}

#if !os(macOS)
    #Preview {
        DynamicNavigation()
    }
#endif
