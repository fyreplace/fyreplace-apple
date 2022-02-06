import PhotosUI
import SDWebImage
import UIKit

class ImageSelector: NSObject {
    static let imageMaxArea = 1920 * 1080
    static let imageChunkSize = 100 * 1024

    @IBOutlet
    weak var delegate: ImageSelectorDelegate!

    func selectImage(canRemove: Bool) {
        let choice = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let library = UIAlertAction(
            title: .tr("ImageSelector.ChooseSource.Action.Library"),
            style: .default,
            handler: { _ in self.selectImage(from: .photoLibrary) }
        )
        let camera = UIAlertAction(
            title: .tr("ImageSelector.ChooseSource.Action.Camera"),
            style: .default,
            handler: { _ in self.selectImage(from: .camera) }
        )

        choice.addAction(library)
        choice.addAction(camera)

        if canRemove {
            let remove = UIAlertAction(
                title: .tr("ImageSelector.ChooseSource.Action.Remove"),
                style: .destructive,
                handler: { _ in self.delegate.onImageRemoved() }
            )
            choice.addAction(remove)
        }

        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)
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

    private func extractImageData(image: UIImage, isPng: Bool) {
        guard var data = isPng ? image.pngData() : image.jpegData(compressionQuality: 1.0) else { return }

        if data.count >= delegate.maxImageBytes {
            guard let newData = image.downscaled()?.jpegData(compressionQuality: 0.5) else { return }
            data = newData
        }

        guard data.count < delegate.maxImageBytes else {
            delegate.presentBasicAlert(text: "ImageSelector.Error.Size", feedback: .error)
            return
        }

        DispatchQueue.main.async {
            self.delegate.onImageSelected(data)
        }
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

        DispatchQueue.global(qos: .userInitiated).async {
            self.extractImageData(image: image, isPng: url?.pathExtension == "png")
        }
    }
}

@available(iOS 14, *)
extension ImageSelector: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self)
        else { return }

        provider.loadObject(ofClass: UIImage.self) { image, error in
            guard let image = image as? UIImage, error == nil else {
                self.delegate.presentBasicAlert(text: "Error", feedback: .error)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                self.extractImageData(image: image, isPng: image.sd_imageFormat == .PNG)
            }
        }
    }
}

@objc
protocol ImageSelectorDelegate where Self: UIViewController {
    static var maxImageSize: Float { get }

    func onImageSelected(_ image: Data)

    func onImageRemoved()
}

private extension ImageSelectorDelegate {
    var maxImageBytes: Int { Int(Self.maxImageSize * 1024 * 1024) }
}

private extension UIImage {
    func downscaled() -> UIImage? {
        let factor = (size.width * size.height * scale) / CGFloat(ImageSelector.imageMaxArea)

        if factor <= 1 {
            return self
        }

        let newWidth = size.width / factor
        let newHeight = size.height / factor
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
