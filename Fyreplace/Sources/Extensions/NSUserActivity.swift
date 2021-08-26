import Foundation

extension NSUserActivity {
    func sendNotification() -> Bool {
        guard activityType == NSUserActivityTypeBrowsingWeb, let url = webpageURL else { return false }
        NotificationCenter.default.post(name: AppDelegate.urlOpenedNotification, object: self, userInfo: ["url": url])
        return true
    }
}
