import Foundation

public extension Array {
    subscript(_ index: Int, default defaultValue: Element?) -> Element? {
        guard index >= 0, index < count else { return defaultValue }
        return self[index]
    }
}
