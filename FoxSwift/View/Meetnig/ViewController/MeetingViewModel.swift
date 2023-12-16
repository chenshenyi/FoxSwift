//
//  MeetingViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import Speech
import UIKit

class MeetingViewModel {
    // MARK: - Network Provider
    private let rtcMannager: MeetingParticipantManager
    private let messageProvider: MessageProvider
    private let speechRecognitionManager = SpeechRecognitionManager()

    // MARK: - Binded Properties
    var meetingCode: Box<String> = .init("")
    var participants: DiffBox<Participant> = .init([.currentUser])
    var sharer: Box<Participant?> = .init(semaphore: 1)

    let meetingInformationViewModel = MeetingInformationViewModel()

    var isOnMic = Box(true)
    var isOnCamera = Box(true)
    var isMessage = Box(false)
    var isSharingScreen = Box(false)

    enum LayoutMode {
        case oneColumn
        case twoColumn
        case topRow(Int)
    }

    var layoutMode = Box(LayoutMode.oneColumn)

    // MARK: - Init
    init(meetingCode: String) {
        self.meetingCode = .init(meetingCode)

        rtcMannager = .init(meetingCode: meetingCode)

        messageProvider = .init(meetingCode: meetingCode)

        setupProvider()
    }

    func setupProvider() {
        rtcMannager.delegate = self
        speechRecognitionManager.delegate = self

        rtcMannager.connect()
    }

    // MARK: - Request speechRecognition
    func requestSpeechRecognition() {
        speechRecognitionManager.enableRecording()
    }

    // MARK: - Fetch video
    func fetchVideo(into view: UIView, for participant: Participant) {
        rtcMannager.fetchVideo(into: view, for: participant)
        view.layoutIfNeeded()
    }

    func fetchScreenSharing(into view: UIView, for participant: Participant) {
        rtcMannager.fetchScreenSharing(into: view, for: participant)
        view.layoutIfNeeded()
    }

    func startScreenSharing() {
        isSharingScreen.value = rtcMannager.startScreenSharing()
        sharer.value = Participant.currentUser
        updateLayout()
    }

    func stopScreenSharing() {
        isSharingScreen.value = false
        rtcMannager.stopScreenSharing()
        if sharer.value?.id == Participant.currentUser.id {
            sharer.value = nil
        }
        updateLayout()
    }

    // MARK: - Leave Meet
    func leaveMeet() {
        speechRecognitionManager.disableRecording()
        rtcMannager.leave()
    }

    // MARK: - Functional Buttons
    func turnOffMic() {
        isOnMic.value = false
        rtcMannager.turnOffMic()
        speechRecognitionManager.disableRecording()
    }

    func turnOnMic() {
        isOnMic.value = true
        rtcMannager.turnOnMic()
        speechRecognitionManager.enableRecording()
    }

    func turnOnAudio() {
        rtcMannager.turnOnAudio()
    }

    func turnOffAudio() {
        rtcMannager.turnOffAudio()
    }

    func turnOnCamera() {
        isOnCamera.value = true
        rtcMannager.turnOnCamera()
    }

    func turnOffCamera() {
        isOnCamera.value = false
        rtcMannager.turnOffCamera()
    }

    func showMessage() {
        isMessage.value = true
        updateLayout()
    }

    func hideMessage() {
        isMessage.value = false
        updateLayout()
    }

    func updateLayout() {
        let participantsAmount = participants.value.count + (sharer.value == nil ? 0 : 1)
        if isMessage.value {
            layoutMode.value = .topRow(participantsAmount)
        } else if participantsAmount > 2 {
            layoutMode.value = .twoColumn
        } else {
            layoutMode.value = .oneColumn
        }
    }
}

// MARK: - MeetingRoomProviderDelegate
extension MeetingViewModel: MeetingParticipantManagerDelegate {
    func meetingRoom(
        _ manager: MeetingParticipantManager,
        startSharingScreen participant: Participant
    ) {
        sharer.value = participant
        updateLayout()
    }

    func meetingRoom(
        _ manager: MeetingParticipantManager,
        stopSharingScreen participant: Participant
    ) {
        if sharer.value?.id == participant.id {
            sharer.value = nil
        }
        updateLayout()
    }

    func meetingRoom(
        _ manager: MeetingParticipantManager,
        didRecieveInitial participants: [Participant]
    ) {
        self.participants.value += participants
        meetingInformationViewModel.update(participants: self.participants.value)
        updateLayout()
    }

    func meetingRoom(
        _ manager: MeetingParticipantManager,
        didRecieveNew participants: [Participant]
    ) {
        self.participants.value += participants
        meetingInformationViewModel.update(participants: self.participants.value)
        updateLayout()
    }

    func meetingRoom(
        _ manager: MeetingParticipantManager,
        didRecieveLeft participants: [Participant]
    ) {
        participants.forEach { participant in
            self.participants.value.removeAll { participant == $0 }
        }
        meetingInformationViewModel.update(participants: self.participants.value)
        updateLayout()
    }
}

// MARK: - Speech Provider Delegate
extension MeetingViewModel: SpeechRecognitionManagerDelegate {
    func startSpeechRecognition(_ manager: SpeechRecognitionManager) {
//        print("Start Recognition")
    }

    func speechTimeOutResult(_ manager: SpeechRecognitionManager, _ ret: String) {
        guard !ret.isEmpty else { return }
        guard let data = ret.data(using: .utf8) else { return }
        let message: FSMessage = .init(data: data, author: .currentUser, type: .speechText)
        messageProvider.send(message: message)
    }

    func speechFinalResult(_ manager: SpeechRecognitionManager, _ ret: String) {
//        guard !ret.isEmpty else { return }
//        guard let data = ret.data(using: .utf8) else { return }
//        let message: FSMessage = .init(data: data, author: .currentUser, type: .speechText)
//        messageProvider.send(message: message)
    }
}
