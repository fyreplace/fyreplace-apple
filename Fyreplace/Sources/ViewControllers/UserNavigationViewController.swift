import UIKit

class UserNavigationViewController: UINavigationController {
    var currentProfile: FPProfile?
    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in viewControllers {
            if let controller = controller as? UserViewController {
                controller.currentProfile = currentProfile
                controller.profile = profile
            }
        }
    }
}
