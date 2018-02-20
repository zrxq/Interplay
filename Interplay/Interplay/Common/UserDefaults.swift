//
//  UserDefaults.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 2/20/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import Foundation

extension UserDefaults {
    fileprivate static let musicianNameDefaultsKey =  "interplay.musician.name"
    static var musicianName:String? {
        get {
            return UserDefaults.standard.string(forKey: musicianNameDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: musicianNameDefaultsKey)
        }
    }
}
