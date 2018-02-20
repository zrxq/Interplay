//
//  Packet.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 2/13/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import Foundation

enum Packet: Codable {
    case signal(Signal)
    case name(String)
    
    enum CodingKeys: CodingKey {
        case signal
        case name
    }
    
    enum PacketError: Error {
        case unknownPacketError
    }
    
    init(from decoder: Decoder) throws {
        let v = try decoder.container(keyedBy: CodingKeys.self)
        if let signalRaw = try? v.decode(Int.self, forKey: CodingKeys.signal) {
            self = .signal(Signal(rawValue: signalRaw)!)
            return
        }
        if let name = try? v.decode(String.self, forKey: CodingKeys.name) {
            self = .name(name)
            return
        }
        throw PacketError.unknownPacketError
    }
    
    func encode(to encoder: Encoder) throws {
        var v = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .signal(let sig):
            try v.encode(sig.rawValue, forKey: .signal)
        case .name(let name):
            try v.encode(name, forKey: .name)
        }
    }
    
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
}
