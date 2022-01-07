import UIKit

class UserNavigationViewController: UINavigationController {
    var currentUserId: String?
    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in viewControllers {
            if let controller = controller as? UserViewController {
                controller.currentUserId = currentUserId
                controller.profile = profile
            }
        }
    }
}
