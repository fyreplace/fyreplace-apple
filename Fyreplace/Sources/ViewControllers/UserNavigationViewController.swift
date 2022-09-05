import UIKit

class UserNavigationViewController: UINavigationController {
    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()

        for case let controller as UserViewController in viewControllers {
            controller.profile = profile
        }
    }
}
