//
//  WebSocketProvider.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/4/13.
//

import Foundation

extension WebSocket {
    /// Protocol requirement for message types that can be sent/received via WebSocket.
    ///
    /// Messages must be both `Codable` for serialization to/from JSON,
    /// and `Sendable` to ensure thread safety when used with Swift Concurrency.
    ///
    /// Implementers should define message types that conform to this typealias.
    typealias MessageProtocol = Codable & Sendable

    /// A protocol defining the interface for WebSocket communication providers.
    ///
    /// This protocol abstracts the underlying WebSocket implementation,
    /// allowing for different WebSocket providers to be used interchangeably.
    ///
    /// - Note: Implementations must handle message encoding/decoding and connection management.
    ///
    /// Usage example:
    /// ```swift
    /// let provider: some WebSocket.Provider = WebSocket.URLSessionProvider<MyMessage, MyCloseReason>(webSocketTask: task)
    /// try await provider.send(message: MyMessage(...))
    /// let response = try await provider.receive()
    /// ```
    protocol Provider {
        associatedtype Message: MessageProtocol
        associatedtype CloseReason: Close.ReasonProtocol

        /// Sends a ping to check the connection status.
        /// - Throws: Any error that occurs during the ping operation.
        func ping() async throws

        /// Sends a message to the WebSocket server.
        /// - Parameter message: The message to send.
        /// - Throws: Any error that occurs during the send operation.
        func send(message: Message) async throws

        /// Receives a message from the WebSocket server.
        /// - Returns: The received message.
        /// - Throws: Any error that occurs during the receive operation.
        func receive() async throws -> Message

        /// Closes the WebSocket connection with a specified code and reason.
        /// - Parameters:
        ///   - code: The close code indicating the reason for closing.
        ///   - reason: Additional information about why the connection was closed.
        /// - Throws: Any error that occurs during the close operation.
        func close(
            code: URLSessionWebSocketTask.CloseCode,
            reason: CloseReason
        ) async throws

        /// Waits for the WebSocket connection to close and returns information about the closure.
        /// - Returns: Information about how the connection was closed.
        /// - Throws: Any error that occurs while waiting for the connection to close.
        func awaitClosed() async throws -> Close.Info<CloseReason>
    }
}
