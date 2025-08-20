import UIKit

class TextChapterNavigationViewController: UINavigationController {
    var post: FPPost!
    var position: Int!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        for case let controller as TextChapterViewController in viewControllers {
            controller.post = post
            controller.position = position
            controller.text = text
        }
    }
}
