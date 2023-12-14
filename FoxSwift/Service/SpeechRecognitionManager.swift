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
    }

    var status: Status = .none

    var localeIdentifier: String {
//        Locale.current.identifier
        Locale(languageCode: .chinese, script: .hanTraditional, languageRegion: .taiwan).identifier
    }

    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var audioEngine = AVAudioEngine()
    var inputNode: AVAudioNode {
        audioEngine.inputNode
    }

    var recognizedText: String = ""

    // MARK: - Timer
    var recognitionTimer: Timer?
    /** Speech recognition time limit (maximum time 60 seconds is Apple's limit time) */
    var recognitionLimitSec: Int = 30

    /** Threshold for judging period of silence */
    var noAudioDurationTimer: Timer?
    var noAudioDurationLimitSec: Double = 1

    weak var delegate: SpeechRecognitionManagerDelegate?
    
    func enableRecording() {
        status = .ready
        startNewRecording()
    }
    
    func disableRecording() {
        stopRecording()
        status = .none
    }

    private func startNewRecording() {
        if status == .ready {
            status = .listening

            recognizedText = ""
            delegate?.startSpeechRecognition(self)

            try? startAudioEngine()
            startTimer()
        }
    }

    private func stopRecording() {
        if status == .listening {
            status = .ready

            stopAudioEngine()

            stopTimer()
            stopNoAudioDurationTimer()
        }
    }

    private func startAudioEngine() throws {
        // Cancel the previous task if it's running.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        // Configure request if results are returned before audio recording is finished
        guard let recognitionRequest else {
            print("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest, delegate: self)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func stopAudioEngine() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }

        inputNode.removeTap(onBus: 0)
        recognitionTask = nil
        recognitionRequest = nil
    }

    func timeOut(_: Timer) {
        stopRecording()
        delegate?.speechTimeOutResult(self, recognizedText)
        startNewRecording()
    }

    private func startTimer() {
        stopTimer()
        recognitionTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(recognitionLimitSec),
            repeats: false,
            block: timeOut
        )
    }

    private func stopTimer() {
        if recognitionTimer != nil {
            recognitionTimer?.invalidate()
            recognitionTimer = nil
        }
    }

    private func startNoAudioDurationTimer() {
        stopNoAudioDurationTimer()
        noAudioDurationTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(noAudioDurationLimitSec),
            repeats: false,
            block: timeOut
        )
    }

    private func stopNoAudioDurationTimer() {
        if noAudioDurationTimer != nil {
            noAudioDurationTimer?.invalidate()
            noAudioDurationTimer = nil
        }
    }
}

extension SpeechRecognitionManager: SFSpeechRecognitionTaskDelegate {
    // Tells the delegate that a hypothesized transcription is available.
    func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didHypothesizeTranscription transcription: SFTranscription
    ) {
        
        let text = transcription.formattedString
        
        if !text.isEmpty {
            recognizedText = text

            // Start judgment of silent time
            print("Sound".yellow)
            stopNoAudioDurationTimer()
            startNoAudioDurationTimer()
        }
    }

    // Tells the delegate when the task is no longer accepting new audio input, even if final processing is in progress.
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {}

    // Tells the delegate when the final utterance is recognized.
    func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didFinishRecognition recognitionResult: SFSpeechRecognitionResult
    ) {
        stopRecording()
        recognizedText = recognitionResult.bestTranscription.formattedString
        delegate?.speechFinalResult(self, recognizedText)
        startNewRecording()
    }

    // Tells the delegate when the recognition of all requested utterances is finished.
    func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didFinishSuccessfully successfully: Bool
    ) {
        
    }
}
