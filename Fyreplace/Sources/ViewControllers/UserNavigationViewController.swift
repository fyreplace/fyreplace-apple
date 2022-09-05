import UIKit

class UserNavigationViewController: UINavigationController {
    var itemPosition: Int?
    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()

        for case let controller as UserViewController in viewControllers {
            controller.itemPosition = itemPosition
            controller.profile = profile
        }
    }
}
