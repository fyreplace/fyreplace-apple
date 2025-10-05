import UIKit

extension UIImage {
    func resized(at size: CGFloat) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            draw(in: .init(origin: .zero, size: .init(width: size, height: size)))
        }
    }
}
