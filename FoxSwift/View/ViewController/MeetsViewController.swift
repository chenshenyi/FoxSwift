//
//  MeetsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/16.
//

import MapKit
import SnapKit
import UIKit

class MeetsViewController: FSViewController {
    var meetingProvider: MeetingRoomProvider = .init()

    func testMeetingRoom() {}

    let label = UITextView()
    let textField = UITextField()

    var buttons: [UIButton] = []
    func setupButtons() {
        buttons = ["create", "join", "left", "clear"].enumerated().map { index, title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.backgroundColor = .fsPrimary
            view.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(index * 100)
                make.width.height.equalTo(90)
            }
            return button
        }

        buttons[0].addAction { [unowned self] _ in
            meetingProvider.disconnect()
            meetingProvider.delegate = self
            meetingProvider.create()
        }

        buttons[1].addAction { [unowned self] _ in
            if let text = textField.text, !text.isEmpty {
                meetingProvider.disconnect()
                meetingProvider.meetingCode = textField.text
                meetingProvider.delegate = self
                meetingProvider.connect()
                return
            }

            meetingProvider.delegate = self
            meetingProvider.connect()
        }

        buttons[2].addAction { [unowned self] _ in
            meetingProvider.disconnect()
        }

        buttons[3].addAction { _ in
            FSCollectionManager.meetingRoom.clearCollection()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        testMeetingRoom()
        setupButtons()

        label.isEditable = false
        label.textColor = .fsText
        label.backgroundColor = .fsPrimary

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp_bottomMargin).offset(-40)
            make.height.equalTo(30)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }

        textField.backgroundColor = .fsPrimary
        textField.textColor = .fsText
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin).offset(40)
            make.height.equalTo(30)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
    }
}

extension MeetsViewController: MeetingRoomProviderDelegate {
    func meetingRoom(_ provider: MeetingRoomProvider, newMeetingCode: String) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = newMeetingCode
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveUpdate meetingRoom: MeetingRoom) {
        print(meetingRoom)
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError error: Error) {
        print(error)
    }
}
