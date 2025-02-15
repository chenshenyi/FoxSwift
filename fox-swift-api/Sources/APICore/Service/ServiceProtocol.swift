//
//  ServiceProtocol.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import Vapor

public protocol ServiceProtocol {
    var request: Vapor.Request { get }
    init(request: Vapor.Request)
}
