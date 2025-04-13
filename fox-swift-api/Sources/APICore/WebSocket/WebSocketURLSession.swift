//
//  WebSocketURLSession.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/4/13.
//

import Foundation
import AsyncAlgorithms

extension WebSocket {
    /// Errors that can occur during WebSocket operations with URLSessionProvider.
    public enum URLSessionProviderError: Error {
        /// Thrown when an unsupported message type is received.
        case unsupportedMessageType
        /// Thrown when a message couldn't be properly decoded.
        case messageDecodingFailed(Error)
        /// Thrown when a message couldn't be properly encoded.
        case messageEncodingFailed(Error)
    }
    
    public struct URLSessionProvider<Message: Codable&Sendable, CloseReason: Close.ReasonProtocol>: Provider {
        package let webSocketTask: URLSessionWebSocketTask
        package var jsonEncoder: JSONEncoder = JSONEncoder()
        package var jsonDecoder: JSONDecoder = JSONDecoder()

        public var state: URLSessionWebSocketTask.State {
            webSocketTask.state
        }

        init(webSocketTask: URLSessionWebSocketTask) {
            self.webSocketTask = webSocketTask
        }

        public func ping() async throws {
            try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, any Error>) in
                webSocketTask.sendPing { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }

        public func send(message: Message) async throws {
            do {
                let messageData = try jsonEncoder.encode(message)
                try await webSocketTask.send(.data(messageData))
            } catch let error as EncodingError {
                throw URLSessionProviderError.messageEncodingFailed(error)
            }
        }

        public func receive() async throws -> Message {
            let messageData = try await webSocketTask.receive()
            guard case let .data(data) = messageData else {
                throw URLSessionProviderError.unsupportedMessageType
            }
            
            do {
                let message = try jsonDecoder.decode(Message.self, from: data)
                return message
            } catch let error as DecodingError {
                throw URLSessionProviderError.messageDecodingFailed(error)
            }
        }

        public func close(
            code: URLSessionWebSocketTask.CloseCode,
            reason: CloseReason
        ) async throws {
            // 檢查連接是否已經關閉
            guard 
                webSocketTask.state != .canceling,
                webSocketTask.state != .completed 
            else {
                // 連接已經關閉或正在關閉，無需再次關閉
                return
            }
            
            let reason = try jsonEncoder.encode(reason)
            webSocketTask.cancel(with: code, reason: reason)
        }

        public func awaitClosed() async throws -> Close.Info<CloseReason> {
            let delegate = Delegate(jsonDecoder: jsonDecoder)
            webSocketTask.delegate = delegate

            for await closeInfo in delegate.didCloseChannel {
                return closeInfo
            }
            return .deinitBeforeClose
        }
    }
}

extension WebSocket.URLSessionProvider {
    private final class Delegate: NSObject, URLSessionWebSocketDelegate {
        let jsonDecoder: JSONDecoder
        typealias CloseInfo = WebSocket.Close.Info<CloseReason>
        let didCloseChannel = AsyncChannel<CloseInfo>()
        
        // 使用 actor 來管理狀態
        private actor State {
            var isClosed = false
            
            /// 關閉連接
            /// - Returns: 如果連接原本是開啟的，則返回 true，並關閉連接，否則返回 false
            func close() -> Bool {
                let wasOpen = !isClosed
                isClosed = true
                return wasOpen
            }
        }
        
        private let state = State()
        
        init(jsonDecoder: JSONDecoder) {
            self.jsonDecoder = jsonDecoder
            super.init()
        }
        
        deinit {
            Task { [state, didCloseChannel] in
                if await state.close() {
                    didCloseChannel.finish()
                }
            }
        }

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
            reason: Data?
        ) {
            let closeInfo: CloseInfo

            defer {
                sendCloseInfo(closeInfo)
            }

            guard let reasonData = reason else {
                closeInfo = .noReason(code: closeCode)
                return
            }

            do {
                let decodedReason = try jsonDecoder.decode(CloseReason.self, from: reasonData)
                closeInfo = .info(code: closeCode, reason: decodedReason)
            } catch {
                closeInfo = .reasonDecodingFailed(code: closeCode, error: error)
            }
        }
        
        private func sendCloseInfo(_ closeInfo: CloseInfo) {
            Task { [state, didCloseChannel] in
                // 確保 channel 未關閉時才發送
                if await state.close() {
                    await didCloseChannel.send(closeInfo)
                    didCloseChannel.finish()
                }
            }
        }
    }
}
