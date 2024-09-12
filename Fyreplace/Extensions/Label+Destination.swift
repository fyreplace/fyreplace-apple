import SwiftUI

extension Label where Title == Text, Icon == Image {
    init(_ destination: Destination) {
        self.init(destination.titleKey, systemImage: destination.icon)
    }
}
