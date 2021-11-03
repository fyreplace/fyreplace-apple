import UIKit

class Action: UIControl {
    @IBInspectable
    var title: String?
    @IBInspectable
    var icon: UIImage?
    @IBInspectable
    var destructive: Bool = false
}

class Menu: NSObject {
    @IBOutlet
    var actions: [Action] = []
    @IBOutlet
    var controller: UIViewController!
    @IBOutlet
    var item: UIBarButtonItem!

    private var alert: UIAlertController?
    private var visibleActions: [Action] { actions.filter { !$0.isHidden } }

    override func awakeFromNib() {
        super.awakeFromNib()
        reload()
    }
    
    func reload() {
        if #available(iOS 14.0, *) {
            attachMenu()
        } else {
            attachAlert()
        }
    }

    @available(iOS 14.0, *)
    private func attachMenu() {
        let elements = actions.map { action in
            UIAction(
                title: action.title ?? "",
                image: action.icon,
                attributes: action.isHidden ? .hidden : action.destructive ? .destructive : []
            ) { _ in action.sendActions(for: .primaryActionTriggered) }
        }
        item.menu = UIMenu(title: "", image: nil, children: elements)
    }

    private func attachAlert() {
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for action in visibleActions {
            let alertAction = UIAlertAction(
                title: action.title,
                style: action.destructive ? .destructive : .default
            ) { _ in action.sendActions(for: .primaryActionTriggered) }
            alert?.addAction(alertAction)
        }

        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)
        alert?.addAction(cancel)
        item.action = #selector(showAlert)
        item.target = self
    }

    @objc
    private func showAlert() {
        guard let alert = alert else { return }
        controller.present(alert, animated: true)
    }
}
