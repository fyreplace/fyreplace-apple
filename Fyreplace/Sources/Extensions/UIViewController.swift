import UIKit

extension UIViewController {
    func presentBasicAlert(text: String, feedback: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        let alert = UIAlertController(title: .tr("\(text).Title"), message: .tr("\(text).Message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .tr("Ok"), style: .default))
        DispatchQueue.main.async {
            feedbackGenerator.notificationOccurred(feedback)
            self.present(alert, animated: true)
        }
    }
}
