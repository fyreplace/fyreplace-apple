import Combine
import UIKit

extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .map { [weak self] _ in self?.text ?? "" }
            .prepend(text ?? "")
            .eraseToAnyPublisher()
    }
}
