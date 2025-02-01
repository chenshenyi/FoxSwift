//
//  File.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/28.
//

import Foundation
import OSLog
internal import TestableFatal

package enum Fatal: String {
    case methodNotImplement
    case unknown
}

extension Fatal: TestableFatalProtocol {
    static var testableFatal: ((Fatal) -> Void)? = nil
    static let logger: Logger = Logger(subsystem: "FoxSwiftAPI", category: "APICore")
    package var debugDescription: String {
        rawValue
    }
}
