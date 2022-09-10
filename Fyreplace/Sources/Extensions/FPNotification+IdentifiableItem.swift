import Foundation

extension FPNotification: IdentifiableItem {
    var id: Data {
        guard let target = target as? IdentifiableItem else { return .init() }
        var data = target.id
        data.append(isFlag ? 1 : 0)
        return data
    }
}
