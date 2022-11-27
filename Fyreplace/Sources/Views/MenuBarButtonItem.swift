import UIKit

class ActionBarButtonItem: UIBarButtonItem {
    @IBInspectable
    var index: Int = 0
    @IBInspectable
    var isConcealed: Bool = false
    @IBInspectable
    var isDestructive: Bool = false
}

class MenuBarButtonItem: UIBarButtonItem {
    @IBOutlet
    var actions: [ActionBarButtonItem] = []
    @IBOutlet
    weak var navigationDelegate: UIViewController!

    private var alert: UIAlertController?
    private lazy var orderedActions = actions.sorted { a, b in a.index < b.index }
    private var visibleActions: [ActionBarButtonItem] { orderedActions.filter { !$0.isConcealed } }

    override func awakeFromNib() {
        super.awakeFromNib()
        reload()
    }

    func reload() {
        switch visibleActions.count {
        case 0:
            attachNoAction()

        case 1:
            attachSingleAction()

        default:
            attachMultipleActions()
        }
    }

    private func attachNoAction() {
        navigationDelegate.navigationItem.rightBarButtonItems?.removeAll { $0 == self }
    }

    private func attachSingleAction() {
        navigationDelegate.navigationItem.rightBarButtonItem = visibleActions.first
    }

    private func attachMultipleActions() {
        navigationDelegate.navigationItem.rightBarButtonItem = self

        if #available(iOS 14, *) {
            attachMenu()
        } else {
            attachAlert()
        }
    }

    @available(iOS 14, *)
    private func attachMenu() {
        let elements = orderedActions.map { action in
            UIAction(
                title: action.title ?? "",
                image: action.image,
                attributes: action.isConcealed ? .hidden : action.isDestructive ? .destructive : []
            ) { _ in action.execute() }
        }
        menu = UIMenu(title: "", image: nil, children: elements)
    }

    private func attachAlert() {
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for action in visibleActions {
            let alertAction = UIAlertAction(
                title: action.title,
                style: action.isDestructive ? .destructive : .default
            ) { _ in action.execute() }
            alert?.addAction(alertAction)
        }

        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)
        alert?.addAction(cancel)
        action = #selector(showAlert)
        target = self
    }

    @objc
    private func executeSingleAction() {
        visibleActions.first?.execute()
    }

    @objc
    private func showAlert() {
        guard let alert = alert else { return }
        navigationDelegate.present(alert, animated: true)
    }
}
