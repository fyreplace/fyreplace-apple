import SwiftUI

extension Label where Title == Text, Icon == Image {
    init(_ destination: Destination) {
        #if os(macOS)
            let iconSuffix = ""
        #else
            let iconSuffix = UIDevice.current.userInterfaceIdiom == .phone ? ".fill" : ""
        #endif

        self.init(destination.titleKey, systemImage: destination.icon + iconSuffix)
    }
}
