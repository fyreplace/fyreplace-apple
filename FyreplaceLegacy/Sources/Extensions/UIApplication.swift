import UIKit

extension UIApplication {
    var sceneWindows: [UIWindow] {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
    }
    
    func open(url: URL) {
        guard let delegate = delegate as? AppDelegate else { return }
        delegate.open(url: url)
    }
}
