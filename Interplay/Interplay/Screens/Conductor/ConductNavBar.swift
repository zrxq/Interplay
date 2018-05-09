//
//  ConductNavBar.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 4/17/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit
import Cartography

extension ConductViewController {
    
    class ConductNavBar: UINavigationBar, TempoDisplay {
        
        let tempoLabel = UILabel(frame: .zero)
        let logo = UIImageView(image: UIImage(named: "Logo"))
        
        override init(frame: CGRect) {
            self.bpm = TJGDefaultTempo
            super.init(frame: frame)
            barStyle = .black
            isTranslucent = false
            
            addSubview(tempoLabel)
            constrain(tempoLabel) { label in
                label.right == label.superview!.right - 20
                label.top == label.superview!.top + 20
            }
            
            addSubview(logo)
            constrain(logo) { logo in
                logo.left == logo.superview!.left + 20
                logo.top == logo.superview!.top + 20
            }
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("Not supported")
        }
        
        var bpm: Double {
            didSet {
                let text = "\(round(bpm * 100) / 100)"
                tempoLabel.attributedText = NSAttributedString(string: text, attributes: Style.Conductor.tempoAttributes)
            }
        }
        
    }
    
    class func navigationController(context: NetworkingContext, link: Link) -> UINavigationController {
        let navCon = UINavigationController(navigationBarClass: ConductNavBar.self, toolbarClass: nil)
        precondition(navCon.navigationBar is TempoDisplay)
        navCon.viewControllers = [ConductViewController(context: context, link: link, tempoDisplay: navCon.navigationBar as! TempoDisplay), ]
        return navCon
    }
    
}
