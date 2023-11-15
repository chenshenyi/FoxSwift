//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(
        _ signalClient: SignalingClient,
        didReceiveRemoteSdp sdp: RTCSessionDescription
    )
    func signalClient(
        _ signalClient: SignalingClient,
        didReceiveCandidate candidate: RTCIceCandidate
    )
}

final class SignalingClient {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    weak var delegate: SignalClientDelegate?

    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }

    func connect() {
        webSocket.delegate = self
        webSocket.connect()
    }

    func send(sdp rtcSdp: RTCSessionDescription) {
        let message = RTCMessage.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try encoder.encode(message)

            webSocket.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }

    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let message = RTCMessage.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try encoder.encode(message)
            webSocket.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidConnect(self)
    }

    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidDisconnect(self)

        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }

    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: RTCMessage
        do {
            message = try decoder.decode(RTCMessage.self, from: data)
        } catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }

        switch message {
        case let .candidate(iceCandidate):
            delegate?.signalClient(
                self,
                didReceiveCandidate: iceCandidate.rtcIceCandidate
            )
        case let .sdp(sessionDescription):
            delegate?.signalClient(
                self,
                didReceiveRemoteSdp: sessionDescription.rtcSessionDescription
            )
        }
    }

    func webSocket(_ webSocket: WebSocketProvider, didReceiveString string: String) {
        let data = Data(string.utf8)

        let message: RTCMessage
        do {
            message = try decoder.decode(RTCMessage.self, from: data)
        } catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }

        switch message {
        case let .candidate(iceCandidate):
            delegate?.signalClient(
                self,
                didReceiveCandidate: iceCandidate.rtcIceCandidate
            )
        case let .sdp(sessionDescription):
            delegate?.signalClient(
                self,
                didReceiveRemoteSdp: sessionDescription.rtcSessionDescription
            )
        }
    }
}
