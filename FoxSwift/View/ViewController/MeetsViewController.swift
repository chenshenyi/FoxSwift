//
//  MeetsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/16.
//

import MapKit
import SnapKit
import UIKit
import WebRTC

class MeetsViewController: FSViewController {
    var meetingProvider: MeetingRoomProvider = .init()
    var participantDetailProvider: ParticipantDetailProvider = .init()

    var webRTCClient: WebRTCClient?

    let label = UITextView()
    let textField = UITextField()

    var buttons: [UIButton] = []
    func setupButtons() {
        buttons = ["create", "join", "left", "clear", "read"].enumerated().map { index, title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.backgroundColor = .fsPrimary
            view.addSubview(button)
            button.snp.makeConstraints { make in
                make.top.equalTo((index / 4) * 100 + 200)
                make.leading.equalTo(index % 4 * 100)
                make.width.height.equalTo(90)
            }
            return button
        }

        buttons[0].addAction { [unowned self] _ in
            meetingProvider.disconnect()
            meetingProvider.delegate = self
            meetingProvider.create()
        }

        buttons[1].addAction { [weak self] _ in
            guard let self else { return }

            let iceServers = RTCConfig.default.webRTCIceServers
            webRTCClient = WebRTCClient(iceServers: iceServers)
            webRTCClient?.delegate = self
            webRTCClient?.offer { [weak self] sdp in
                guard let self else { return }

                participantDetailProvider.send(sdp: SessionDescription(from: sdp))
            }

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

        buttons[4].addAction { [weak self] _ in
            guard let self else { return }

            participantDetailProvider.read(participantId: Participant.currentUser.id)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupButtons()
        setupLabelandTextFields()

        participantDetailProvider.delegate = self
    }

    func setupLabelandTextFields() {
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

extension MeetsViewController: WebRTCClientDelegate {
    func webRTCClient(
        _ client: WebRTCClient,
        didDiscoverLocalCandidate candidate: RTCIceCandidate
    ) {
        participantDetailProvider.send(iceCandidate: IceCandidate(from: candidate))
    }

    func webRTCClient(
        _ client: WebRTCClient,
        didChangeConnectionState state: RTCIceConnectionState
    ) {}

    func webRTCClient(
        _ client: WebRTCClient,
        didReceiveData data: Data
    ) {}
}

extension MeetsViewController: ParticipantDetailProviderDelegate {
    func didReceive(_ provider: ParticipantDetailProvider, participantDetail: ParticipantDetail) {
        print(participantDetail)
    }
}
