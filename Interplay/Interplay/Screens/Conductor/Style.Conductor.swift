//
//  Style.Conductor.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 2/13/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit

extension Style {
    enum Conductor {
        enum MusiciansCollectionView {
            static let minimumColumnWidth = CGFloat(320)
            static let minimumInteritemSpacing = CGFloat(22)
            static let minimumLineSpacing = CGFloat(2)
            static let sectionInset = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
            static let cellHeight = CGFloat(55)
            static let musicianNameInset = CGFloat(16)
        }
        
        enum MusicianCell {
            static let failureBackgroundColor = UIColor(hex: 0x550000)
        }
        
        static let tempoAttributes: [NSAttributedStringKey : Any] = [ .font: UIFont(name: "InputMono-Regular", size: 25)!, .foregroundColor: activeInformational,  .kern: -0.36 ]
        
    }
}
