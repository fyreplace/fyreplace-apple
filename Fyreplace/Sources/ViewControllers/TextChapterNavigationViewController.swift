import UIKit

class TextChapterNavigationViewController: UINavigationController {
    var postId: Data!
    var position: Int!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in viewControllers {
            if let controller = controller as? TextChapterViewController {
                controller.postId = postId
                controller.position = position
                controller.text = text
            }
        }
    }
}
