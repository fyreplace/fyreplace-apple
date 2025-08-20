import UIKit

class ActionBarButtonItem: UIBarButtonItem {
    @IBInspectable
    var index: Int = 0
    @IBInspectable
    var isConcealed: Bool = false
    @IBInspectable
    var isDestructive: Bool = false
    @IBInspectable
    var needsAuthentication: Bool = false
}

class MenuBarButtonItem: UIBarButtonItem {
    @IBOutlet
    var actions: [ActionBarButtonItem] = []
    @IBOutlet
    weak var navigationDelegate: UIViewController!

    private var alert: UIAlertController?
    private lazy var orderedActions = actions.sorted { a, b in a.index < b.index }
    private var visibleActions: [ActionBarButtonItem] { orderedActions.filter { !$0.isConcealed && (!$0.needsAuthentication || currentUser != nil) } }

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
        attachMenu()
    }

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
}
