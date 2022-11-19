import UIKit

extension UIViewController {
    func presentBasicAlert(text: String, feedback: UINotificationFeedbackGenerator.FeedbackType = .success, then complete: (() -> Void)? = nil) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        let alert = UIAlertController(
            title: .tr("\(text).Title"),
            message: .tr("\(text).Message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: .tr("Ok"), style: .default) { _ in complete?() })
        DispatchQueue.main.async {
            feedbackGenerator.notificationOccurred(feedback)
            self.present(alert, animated: true)
        }
    }

    func presentChoiceAlert(text: String, dangerous: Bool, handler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: .tr("\(text).Title"),
            message: .tr("\(text).Message"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: .tr("Yes"),
                style: dangerous ? .destructive : .default,
                handler: { _ in handler(true) }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: .tr("No"),
                style: .cancel,
                handler: { _ in handler(false) }
            )
        )
        DispatchQueue.main.async { self.present(alert, animated: true) }
    }
}
