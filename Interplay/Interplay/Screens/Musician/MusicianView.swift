//
//  MusicianView.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 2/20/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import Cartography

class MusicianView: UIView {
    let reconnectButton = UIButton(type: .system)
    let nameField = UITextField(frame: .zero)
    let namePromptLabel = UILabel(frame: .zero)
    
    var signal = Signal.stop {
        didSet {
            backgroundColor = Style.color(for: signal, active: true).darkened(amount: 0.1)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        reconnectButton.setTitle(NSLocalizedString("Reconnect", comment: "Musician, reconnect button title"), for: .normal)
        
        nameField.placeholder = NSLocalizedString("e.g. Miles Davis", comment: "Musician, name field placeholder")
        nameField.textColor = Style.Musician.nameFieldTextColorLight
        if #available(iOS 10.0, *) {
            nameField.textContentType = .givenName
        }
        nameField.enablesReturnKeyAutomatically = true
        
        namePromptLabel.textColor = Style.activeInformational
        namePromptLabel.font = UIFont.systemFont(ofSize: 10)
        namePromptLabel.text = NSLocalizedString("tap to change", comment: "Musician, name field tip/prompt label")

        addSubview(reconnectButton)
        addSubview(nameField)
        addSubview(namePromptLabel)
        
        let inset = CGFloat(16)
        constrain(self, reconnectButton, nameField, namePromptLabel) { (view, reconnectButton, nameField, namePromptLabel) in
            reconnectButton.right == view.right - inset
            reconnectButton.bottom == view.bottom - inset
            
            nameField.left == view.left + inset
            nameField.top == view.topMargin + inset
            nameField.right == view.right - inset
            
            namePromptLabel.left == nameField.left
            namePromptLabel.top == nameField.bottom + 2
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Nope.")
    }
}
