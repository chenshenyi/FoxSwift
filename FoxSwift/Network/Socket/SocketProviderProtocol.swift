//
//  SocketProviderProtocol.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/14.
//

import Foundation

protocol SocketProvider {
    associatedtype SocketError: Error

    typealias SocketDataHandler = (Result<SocketData, SocketError>) -> Void
    
    var delegate: any SocketProviderDelegate<Self> { get }

    func connect()

    func send(socketData: SocketData, pong: SocketDataHandler?)

    func disconnect()
}

protocol SocketProviderDelegate<Provider> {
    associatedtype Provider: SocketProvider

    func didConnect(_ provider: Provider)

    func didGet(_ provider: Provider, data: SocketData)

    func didDisconnect(_ provider: Provider)
}
