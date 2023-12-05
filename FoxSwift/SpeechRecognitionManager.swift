//
//  SpeechRecognitionManager.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/28.
//

import AVFAudio
import Foundation
import Speech

protocol SpeechRecognitionManagerDelegate: AnyObject {
    func startSpeechRecognition(_ manager: SpeechRecognitionManager)
    func speechTimeOutResult(_ manager: SpeechRecognitionManager, _ ret: String)
    func speechFinalResult(_ manager: SpeechRecognitionManager, _ ret: String)
}

class SpeechRecognitionManager: NSObject {
    enum Status {
        case none
        case ready
        case listening
        case processing
    }

    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var audioEngine = AVAudioEngine()

    var recognizedText: String = ""

    var recognitionTimer: Timer?
    /** Speech recognition time limit (maximum time 60 seconds is Apple's limit time) */
    var recognitionLimitSec: Int = 30

    var noAudioDurationTimer: Timer?
    /** Threshold for judging period of silence */
    var noAudioDurationLimitSec: Double = 2

    var status: Status = .none

    var localeIdentifier = Locale(
        languageCode: .chinese,
        script: .hanTraditional,
        languageRegion: .taiwan
    ).identifier

    weak var delegate: SpeechRecognitionManagerDelegate?

    var inputNode: AVAudioNode {
        audioEngine.inputNode
    }

    func setRecognitionLimitSec(_ sec: Int) {
        /** Speech recognition time limit (maximum time 60 seconds is Apple's limit time) */
        recognitionLimitSec = sec > 60 ? 60 : sec
    }


    @objc func interruptRecognition() {
        var ret = ""
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            ret = recognizedText
        }
        inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        stopTimer()
        stopNoAudioDurationTimer()
        delegate?.speechTimeOutResult(self, ret)
    }

    func startNewRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            inputNode.removeTap(onBus: 0)
            stopTimer()
        } else {
            delegate?.startSpeechRecognition(self)
            recognizedText = ""
            try? startRecording()
            startTimer()
        }
    }

    private func startRecording() throws {
        // Cancel the previous task if it's running.
        if let recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }

        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))

        recognizer?.recognitionTask(with: recognitionRequest, delegate: self)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }

    private func startTimer() {
        recognitionTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(recognitionLimitSec),
            target: self,
            selector: #selector(interruptRecognition),
            userInfo: nil,
            repeats: false
        )
    }

    private func stopTimer() {
        if recognitionTimer != nil {
            recognitionTimer?.invalidate()
            recognitionTimer = nil
        }
    }

    private func startNoAudioDurationTimer() {
        stopTimer()
        noAudioDurationTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(noAudioDurationLimitSec),
            target: self,
            selector: #selector(interruptRecognition),
            userInfo: nil,
            repeats: false
        )
    }

    private func stopNoAudioDurationTimer() {
        if noAudioDurationTimer != nil {
            noAudioDurationTimer?.invalidate()
            noAudioDurationTimer = nil
        }
    }

    private func resetSRMethod() {
        stopNoAudioDurationTimer()
        stopTimer()
        interruptRecognition()
        status = .ready
        startNewRecording()
    }
}

extension SpeechRecognitionManager: SFSpeechRecognitionTaskDelegate {
    // Tells the delegate that a hypothesized transcription is available.
    func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didHypothesizeTranscription transcription: SFTranscription
    ) {
        recognizedText = transcription.formattedString

        if status == .ready {
            // Stop voice recognition
            // Create new voice recognition
            stopNoAudioDurationTimer()
            stopTimer()
            interruptRecognition()
            return
        }
        // Start judgment of silent time
        stopNoAudioDurationTimer()
        startNoAudioDurationTimer()
    }

    // Tells the delegate when the task is no longer accepting new audio input, even if final processing is in progress.
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {}

    // Tells the delegate when the final utterance is recognized.
    func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didFinishRecognition recognitionResult: SFSpeechRecognitionResult
    ) {
        recognizedText = recognitionResult.bestTranscription.formattedString
    }

    // Tells the delegate when the recognition of all requested utterances is finished.
    func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didFinishSuccessfully successfully: Bool
    ) {
        if status == .ready {
            status = .listening
            startNewRecording()
            return
        }

        stopNoAudioDurationTimer()
        delegate?.speechFinalResult(self, recognizedText)
        resetSRMethod()
    }
}
