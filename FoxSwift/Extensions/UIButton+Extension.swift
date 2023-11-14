import UIKit

extension UIButton {
    func addAction(handler: @escaping UIActionHandler, 
                   for event: UIControl.Event = .touchUpInside) {
        let action = UIAction { action in
            handler(action)
        }
        addAction(action, for: event)
    }
}
