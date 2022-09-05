import UIKit

class CommentNavigationViewController: UINavigationController {
    var postId: Data!

    override func viewDidLoad() {
        super.viewDidLoad()

        for case let controller as CommentViewController in viewControllers {
            controller.postId = postId
        }
    }
}
