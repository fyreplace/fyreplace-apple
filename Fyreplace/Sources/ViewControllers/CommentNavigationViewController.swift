import UIKit

class CommentNavigationViewController: UINavigationController {
    var postId: Data!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        for case let controller as CommentViewController in viewControllers {
            controller.postId = postId
            controller.text = text
        }
    }
}
