//
//  LobbyView.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/13/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit
import Cartography

extension LobbyViewController {
    class LobbyView: UIView {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        let conductButton = UIButton(type: .custom)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            
            spinner.color = Style.activeInformational
            spinner.hidesWhenStopped = true
            addSubview(spinner)
            
            conductButton.setTitle(NSLocalizedString("Conduct", comment: "Lobby, `become conductor` button title"), for: .normal)
            addSubview(conductButton)
            conductButton.alpha = 0
            
            constrain(conductButton) { (conductButton) in
                conductButton.centerX == conductButton.superview!.centerX
                conductButton.bottom == conductButton.superview!.bottom - 32
            }
        }
        
        override func didMoveToWindow() {
            guard let window = window else {
                return
            }
            constrain(spinner, window) { (spinner, window) in
                spinner.centerX == window.centerX
                spinner.centerY == window.centerY
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("Not implemented.")
        }
        
        func enableConductButton(after delay:TimeInterval) {
            UIView.animate(withDuration: 1, delay: delay, options: .curveLinear, animations: {
                self.conductButton.alpha = 1
            }, completion: nil)
        }
        
        func disableConductButton() {
            self.conductButton.alpha = 0
        }
        
    }
}
