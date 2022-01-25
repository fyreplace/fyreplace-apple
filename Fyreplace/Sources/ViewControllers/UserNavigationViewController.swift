import UIKit

class UserNavigationViewController: UINavigationController {
    var itemPosition: Int?
    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in viewControllers {
            if let controller = controller as? UserViewController {
                controller.itemPosition = itemPosition
                controller.profile = profile
            }
        }
    }
}
