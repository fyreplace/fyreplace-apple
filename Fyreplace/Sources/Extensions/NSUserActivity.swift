import UIKit

extension NSUserActivity {
    func sendNotification() -> Bool {
        guard activityType == NSUserActivityTypeBrowsingWeb,
              let url = webpageURL
        else { return false }
        UIApplication.shared.open(url: url)
        return true
    }
}
