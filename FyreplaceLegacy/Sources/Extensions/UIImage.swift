import UIKit

extension UIImage {
    func resized(at size: CGFloat) -> UIImage? {
        let smallestSide = min(self.size.width, self.size.height)
        guard let cropped = sd_resizedImage(with: .init(width: smallestSide, height: smallestSide), scaleMode: .aspectFill) else { return nil }
        return UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
            .image { _ in cropped.draw(in: .init(origin: .zero, size: .init(width: size, height: size))) }
    }
}
