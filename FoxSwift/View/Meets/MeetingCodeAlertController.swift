//
//  MeetingCodeAlertController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import UIKit

class MeetingCodeAlertController: UIAlertController {
    enum AlertType {
        case new(meetingCode: MeetingRoom.MeetingCode)
        case join

        var title: String {
            switch self {
            case .new: return "New FoxSwift Meeting"
            case .join: return "Join a Meeting"
            }
        }

        var message: String {
            switch self {
            case .new: return "Start a new meeting and share the meeting code with others."
            case .join: return "Enter the meeting code shared by the meeting organizer."
            }
        }
    }

    var meetingCode: MeetingRoom.MeetingCode = ""

    convenience init(alertType: AlertType) {
        let title = alertType.title
        let message = alertType.message
        self.init(title: title, message: message, preferredStyle: .actionSheet)

        switch alertType {
        case .new(let meetingCode):
            self.meetingCode = meetingCode
            setupTextField()
            addAction(UIAlertAction(title: "Share", style: .default, handler: nil))
        case .join:
            addAction(UIAlertAction(title: "Join", style: .default, handler: nil))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupTextField() {
        addTextField { [weak self] textField in
            guard let self else { return }

            textField.text = meetingCode
        }
    }
}
