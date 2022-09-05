import UIKit

class TextChapterNavigationViewController: UINavigationController {
    var postId: Data!
    var position: Int!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        for case let controller as TextChapterViewController in viewControllers {
            controller.postId = postId
            controller.position = position
            controller.text = text
        }
    }
}
