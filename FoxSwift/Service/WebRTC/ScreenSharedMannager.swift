//
//  ScreenSharedMannager.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/5.
//

import ReplayKit
import WebRTC

class ScreenSharedMannager {
    typealias BufferHandler = (RTCVideoFrame) -> Void

    let screenRecorder = RPScreenRecorder.shared()

    func startSharing(bufferHandler: @escaping BufferHandler) {
        screenRecorder.isMicrophoneEnabled = false
        screenRecorder.startCapture { sampleBuffer, sampleBufferType, error in
            if let error {
                print(error.localizedDescription.red)
                return
            }

            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let buffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
            let timeStamp = Int64(Date().timeIntervalSince1970 * 1e6)
            let frame = RTCVideoFrame(buffer: buffer, rotation: ._0, timeStampNs: timeStamp)

            switch sampleBufferType {
            case .video: bufferHandler(frame)
            default: return
            }
        } completionHandler: { error in
            guard let error else { return }
            print(error.localizedDescription.red)
        }
    }

    func stopSharing() {
        if screenRecorder.isRecording {
            screenRecorder.stopCapture()
        }
    }
}
