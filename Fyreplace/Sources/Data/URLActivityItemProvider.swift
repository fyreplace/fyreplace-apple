import LinkPresentation
import UIKit

open class URLActivityItemProvider: UIActivityItemProvider {
    override open var item: Any { url }
    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(placeholderItem: url)
    }

    @available(iOS 13, *)
    override open func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        let iconUrl = Bundle.main.url(forResource: "AppIcon", withExtension: nil)
        metadata.iconProvider = NSItemProvider(contentsOf: iconUrl)
        return metadata
    }
}
