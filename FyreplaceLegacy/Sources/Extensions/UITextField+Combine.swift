import Combine
import UIKit

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        controlPublisher(for: .editingChanged)
            .map { [weak self] in self?.text ?? "" }
            .prepend(text ?? "")
            .eraseToAnyPublisher()
    }

    private func controlPublisher(for event: UIControl.Event) -> AnyPublisher<Void, Never> {
        return Publishers.ControlEvent(control: self, events: event)
            .eraseToAnyPublisher()
    }
}
