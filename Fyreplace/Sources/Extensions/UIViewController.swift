import UIKit

extension UIViewController {
    func presentBasicAlert(text: String, feedback: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        let alert = UIAlertController(
            title: .tr("\(text).Title"),
            message: .tr("\(text).Message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: .tr("Ok"), style: .default))
        DispatchQueue.main.async { [unowned self] in
            feedbackGenerator.notificationOccurred(feedback)
            present(alert, animated: true)
        }
    }

    func presentChoiceAlert(text: String, dangerous: Bool, handler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: .tr("\(text).Title"),
            message: .tr("\(text).Message"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: .tr("Yes"),
                style: dangerous ? .destructive : .default
            ) { _ in handler() }
        )
        alert.addAction(UIAlertAction(title: .tr("No"), style: .cancel))
        DispatchQueue.main.async { [unowned self] in present(alert, animated: true) }
    }
}
