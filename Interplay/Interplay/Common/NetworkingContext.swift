//
//  NetworkingContext.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import MultipeerConnectivity

final class NetworkingContext {
    let localPeerID: MCPeerID
    let serviceType: String
    init(displayName:String, serviceType:String) {
        localPeerID = MCPeerID(displayName: displayName)
        self.serviceType = serviceType
    }
}
