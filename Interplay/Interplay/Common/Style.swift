//
//  Style.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/13/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit
import DynamicColor

enum Style {
    static let defaultTint = UIColor.white
    static let windowBackground = UIColor.black
    static let panelBackground = UIColor(hexString:"#1A1A1A")
    static let activeInformational = UIColor.white
    static let cornersMask = UIImage(named: "CornersMask")
    
    static func color(for signal:Signal, active:Bool) -> UIColor {
        if active {
            switch signal {
            case .stop: return UIColor(hexString:"#FE4101")
            case .ready: return UIColor(hexString:"#FEBD01")
            case .play: return UIColor(hexString:"#00EC81")
            }
        } else {
            switch signal {
            case .stop: return UIColor(hexString:"#260A00")
            case .ready: return UIColor(hexString:"#261D00")
            case .play: return UIColor(hexString:"#012313")
            }
        }
    }
    
}
