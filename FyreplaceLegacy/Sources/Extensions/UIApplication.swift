import UIKit

extension UIApplication {
    func open(url: URL) {
        guard let delegate = delegate as? AppDelegate else { return }
        delegate.open(url: url)
    }
}
