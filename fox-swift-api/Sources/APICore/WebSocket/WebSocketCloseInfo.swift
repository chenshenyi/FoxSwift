//
//  WebSocketCloseInfo.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/4/13.
//

import Foundation

extension WebSocket {
    /// Namespace for WebSocket connection close-related types and functionality.
    public enum Close {
        /// Protocol requirement for close reason types.
        /// Must be both `Codable` for serialization and `Sendable` for concurrency safety.
        public typealias ReasonProtocol = Codable & Sendable

        /// Represents information about how a WebSocket connection was closed.
        ///
        /// This enum captures various scenarios when a WebSocket connection closes,
        /// including successful closures with reason data, closures where the reason couldn't be decoded,
        /// closures without a reason, and cases where the connection object was deallocated before closure.
        ///
        /// - Note: Generic over the `Reason` type, which must conform to `ReasonProtocol`.
        public enum Info<Reason: ReasonProtocol>: Sendable {
            /// Type alias for URLSessionWebSocketTask's close code type.
            public typealias Code = URLSessionWebSocketTask.CloseCode

            /// The connection closed with a specific code and reason.
            case info(code: Code, reason: Reason)

            /// The connection closed with a code, but the reason data couldn't be decoded.
            case reasonDecodingFailed(code: Code, error: Error)

            /// The connection closed with a code, but no reason was provided.
            case noReason(code: Code)

            /// The connection object was deallocated before the connection closed.
            case deinitBeforeClose
        }
    }
}
