import UIKit

extension UIButton {
    func addAction(
        handler: @escaping UIActionHandler,
        for event: UIControl.Event = .touchUpInside
    ) {
        let action = UIAction { action in
            handler(action)
        }
        addAction(action, for: event)
    }

    func addAction(
        handler: @escaping () -> Void,
        for event: UIControl.Event = .touchUpInside
    ) {
        addAction(handler: { _ in
            handler()
        }, for: event)
    }
}
