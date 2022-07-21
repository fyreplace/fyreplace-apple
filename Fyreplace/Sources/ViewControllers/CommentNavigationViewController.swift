import UIKit

class CommentNavigationViewController: UINavigationController {
    var postId: Data!

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in viewControllers {
            if let controller = controller as? CommentViewController {
                controller.postId = postId
            }
        }
    }
}
