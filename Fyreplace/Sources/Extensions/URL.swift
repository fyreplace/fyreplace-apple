import UIKit

extension URL {
    func browse() {
        UIApplication.shared.open(self)
    }
}
