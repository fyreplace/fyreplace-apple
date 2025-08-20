import Foundation

extension CGFloat {
    #if os(macOS)
        static var logoSize: Self { 60 }
    #else
        static var logoSize: Self { 80 }
    #endif
}

extension String {
    static var randomUuid: String {
        UUID().uuidString
    }
}
