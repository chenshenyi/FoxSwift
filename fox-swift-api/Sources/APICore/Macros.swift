//
//  Macros.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import APIPlugin

@attached(peer, names: suffixed(RouteCollection), suffixed(ServiceProtocol))
public macro Service(_ typeName: String? = nil) = #externalMacro(module: "APIPlugin", type: "ServiceMacro")
