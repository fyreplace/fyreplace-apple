import Kingfisher
import PhotosUI
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
            ) { _ in self.delegate.onImageRemoved() }
            choice.addAction(remove)
        }

        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel) { _ in
            self.delegate.onImageSelectionCancelled()
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

    private func extractImageData(image: UIImage, isPng: Bool) {
        guard var data = isPng ? image.pngData() : image.jpegData(compressionQuality: 0.75)
        else { return }
        let downscaleFactor = Float(data.count) / Float(delegate.maxImageByteSize)

        if downscaleFactor >= 1 {
            guard let newData = image.downscaled(withFactor: downscaleFactor).jpegData(compressionQuality: 0.5) else {
                return delegate.presentBasicAlert(text: "Error", feedback: .error)
            }
            data = newData
        }

        DispatchQueue.main.async { self.delegate.onImageSelected(data) }
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
                return self.delegate.presentBasicAlert(text: "Error", feedback: .error)
            }

            DispatchQueue.global(qos: .userInitiated).async {
                self.extractImageData(image: image, isPng: false)
            }
        }
    }
}

@objc
protocol ImageSelectorDelegate where Self: UIViewController {
    var maxImageByteSize: Int { get }

    func onImageSelected(_ image: Data)

    func onImageRemoved()

    func onImageSelectionCancelled()
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
