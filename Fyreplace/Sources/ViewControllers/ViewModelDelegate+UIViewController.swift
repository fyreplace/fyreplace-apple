import UIKit

extension ViewModelDelegate where Self: UIViewController {
    func presentBasicAlert(title: String, message: String, feedback: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        let alert = UIAlertController(title: .tr(title), message: .tr(message), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .tr("Ok"), style: .default))
        DispatchQueue.main.async {
            feedbackGenerator.notificationOccurred(feedback)
            self.present(alert, animated: true)
        }
    }
}
