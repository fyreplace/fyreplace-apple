import PhotosUI
import SDWebImage
import UIKit

class ImageSelector: NSObject {
    static let imageChunkSize = 100 * 1024

    @IBOutlet
    weak var delegate: ImageSelectorDelegate!

    func selectImage(canRemove: Bool) {
        let choice = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let library = UIAlertAction(
            title: .tr("ImageSelector.ChooseSource.Action.Library"),
            style: .default
        ) { _ in self.selectImage(from: .photoLibrary) }
        let camera = UIAlertAction(
            title: .tr("ImageSelector.ChooseSource.Action.Camera"),
            style: .default
        ) { _ in self.selectImage(from: .camera) }

        choice.addAction(library)
        choice.addAction(camera)

        if canRemove {
            let remove = UIAlertAction(
                title: .tr("ImageSelector.ChooseSource.Action.Remove"),
                style: .destructive
            ) { _ in self.delegate.imageSelector(self, didSelectImage: nil) }
            choice.addAction(remove)
        }

        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel) { _ in
            self.delegate.didNotSelectImage(self)
        }

        choice.addAction(cancel)
        delegate.present(choice, animated: true)
    }

    private func selectImage(from source: UIImagePickerController.SourceType) {
        let picker: UIViewController

        if #available(iOS 14, *), source != .camera {
            picker = makeSelectPicturePicker()
        } else {
            picker = makeSelectPictureOrPhotoPicker(from: source)
        }

        delegate.present(picker, animated: true)
    }

    @available(iOS 14, *)
    private func makeSelectPicturePicker() -> UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        return picker
    }

    private func makeSelectPictureOrPhotoPicker(from source: UIImagePickerController.SourceType) -> UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        return picker
    }

    private func extractImageData(image: UIImage, as format: SDImageFormat) {
        let data: Data?

        switch format {
        case .JPEG:
            data = image.jpegData(compressionQuality: 1)

        case .PNG:
            data = image.pngData()

        default:
            data = image.sd_imageData(as: format)
        }

        guard var data else {
            return delegate.presentBasicAlert(text: .tr("ImageSelector.Error.Format"))
        }

        let downscaleFactor = Float(data.count) / Float(delegate.maxImageByteSize)

        if downscaleFactor >= 1 {
            guard let newData = image.downscaled(withFactor: downscaleFactor).sd_imageData(as: format, compressionQuality: 0.5) else {
                return delegate.presentBasicAlert(text: "Error", feedback: .error)
            }

            data = newData
        }

        DispatchQueue.main.async { self.delegate.imageSelector(self, didSelectImage: data) }
    }
}

extension ImageSelector: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else { return }
        let url = info[.imageURL] as? NSURL
        let format: SDImageFormat

        switch url?.pathExtension {
        case "webp":
            format = .webP

        case "png":
            format = .PNG

        default:
            format = .JPEG
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.extractImageData(image: image, as: format)
        }
    }
}

@available(iOS 14, *)
extension ImageSelector: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let acceptedTypes: [UTType] = [.webP, .png, .jpeg, .image]
        guard let provider = results.first?.itemProvider,
              let identifier = acceptedTypes.map(\.identifier).first(where: provider.hasItemConformingToTypeIdentifier)
        else { return delegate.presentBasicAlert(text: .tr("ImageSelector.Error.Format")) }
        let format: SDImageFormat

        switch identifier {
        case UTType.webP.identifier:
            format = .webP

        case UTType.png.identifier:
            format = .PNG

        default:
            format = .JPEG
        }

        provider.loadDataRepresentation(forTypeIdentifier: identifier) { data, error in
            guard let data, let image = UIImage(data: data), error == nil else {
                return self.delegate.presentBasicAlert(text: "ImageSelector.Error.Format", feedback: .error)
            }

            DispatchQueue.global(qos: .userInitiated).async { self.extractImageData(image: image, as: format) }
        }
    }
}

@objc
protocol ImageSelectorDelegate where Self: UIViewController {
    var maxImageByteSize: Int { get }

    func imageSelector(_ imageSelector: ImageSelector, didSelectImage image: Data?)

    func didNotSelectImage(_ imageSelector: ImageSelector)
}

private extension UIImage {
    func downscaled(withFactor factor: Float) -> UIImage {
        guard factor > 1 else { return self }
        let sideFactor = CGFloat(sqrt(factor))
        let newWidth = size.width / sideFactor
        let newHeight = size.height / sideFactor
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
