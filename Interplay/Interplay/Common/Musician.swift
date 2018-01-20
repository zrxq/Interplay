//
//  File.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/20/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import MultipeerConnectivity

struct Musician {
    let peerID: MCPeerID
    var name: String
    var state: State
    
    init(with peerID:MCPeerID) {
        self.peerID = peerID
        name = peerID.displayName
        state = .initial
    }
    
    static func factoryDefaultMusicianName() -> String {
        return UIDevice.current.name
    }
}

enum Signal: Int, ValueEnumerable {
    case stop = 0
    case ready
    case play
}

extension Musician {
    enum State {
        case initial
        case connecting
        case signalSending(Signal)
        case signalConfirmed(Signal)
        case failure(Error)
    }
}
