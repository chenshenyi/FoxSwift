//
//  NativeWebSocket.swift
//  STYLiSH
//
//  Created by chen shen yi on 2023/11/6.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class NativeWebSocket: NSObject, WebSocketProvider {
    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = .init(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )

    init(url: URL) {
        self.url = url
        super.init()
    }

    /// start a webSocketTask and wait for receive massage
    func connect() {
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        readMessage()
    }

    /// Let socket send data
    func send(data: Data) {
        socket?.send(.data(data)) { _ in }

        socket?.sendPing { error in
            print(error?.localizedDescription ?? "success")
        }
    }

    /// Read message continuously, if fail end the connect
    private func readMessage() {
        socket?.receive { [weak self] message in
            guard let self else { return }

            switch message {
            case let .success(.data(data)):
                delegate?.webSocket(self, didReceiveData: data)
                readMessage()

            case let .success(.string(string)):
                delegate?.webSocket(self, didReceiveString: string)
                readMessage()

            case .failure:
                disconnect()
            case .success:
                break
            }
        }
    }

    /// Cancel socket and inform delegate
    private func disconnect() {
        socket?.cancel()
        socket = nil
        delegate?.webSocketDidDisconnect(self)
    }
}

@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        delegate?.webSocketDidConnect(self)
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        disconnect()
    }
}
