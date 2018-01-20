//
//  MusicianCell.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/20/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit

extension ConductViewController {
    class MusicianCell: UICollectionViewCell {
                
        let nameBackgroundView = UIImageView(image: Style.cornersMask)
        let buttons: [UIButton]
        let nameLabel = UILabel(frame: .zero)
        let connectingLabel = UILabel(frame: .zero)
        
        var name: String? {
            didSet {
                nameLabel.text = name
            }
        }
        
        func disableButtons() {
            for aButton in buttons {
                aButton.tintColor = Style.panelBackground
                aButton.isEnabled = false
            }
        }
        
        var state = Musician.State.initial {
            didSet {
                // remove animations & re-enable buttons
                for aButton in buttons {
                    aButton.layer.removeAllAnimations()
                    aButton.isEnabled = true
                }
                
                // "connecting..."
                connectingLabel.isHidden = true
                connectingLabel.text = NSLocalizedString("Connecting...", comment: "Conductor, musician cell, 'peer is attempting to connect' indicator")

                // name background
                nameBackgroundView.tintColor = Style.panelBackground

                switch state {
                case .initial:
                    disableButtons()
                case .connecting:
                    disableButtons()
                    connectingLabel.isHidden = false
                case .failure(_):
                    for aButton in buttons {
                        aButton.tintColor = Style.Conductor.MusicianCell.failureBackgroundColor
                        aButton.isEnabled = false
                    }
                    connectingLabel.isHidden = false
                    nameBackgroundView.tintColor = Style.Conductor.MusicianCell.failureBackgroundColor
                    connectingLabel.text = NSLocalizedString("Network Failed", comment: "Conductor, musician cell, 'network failure' indicator")

                case .signalSending(let signal):
                    for aButton in buttons {
                        let buttonSignal = Signal(rawValue: aButton.tag)!
                        let active = signal == buttonSignal
                        if (active) {
                            aButton.tintColor = Style.color(for: buttonSignal, active:true).darkened()
                            aButton.layer.add(signalSentAnimation(), forKey: "blink")
                        } else {
                            aButton.tintColor = Style.color(for: buttonSignal, active:false)
                        }
                    }
                    
                case .signalConfirmed(let signal):
                    for aButton in buttons {
                        let buttonSignal = Signal(rawValue: aButton.tag)!
                        aButton.tintColor = Style.color(for: buttonSignal, active: buttonSignal == signal)
                    }
                }
            }
        }
        
        var onSignalSelected: ((Signal)->())? = nil
        
        override init(frame: CGRect) {
            var buttons = [UIButton]()
            for aSignal in Signal.allValues {
                let aButton = UIButton()
                aButton.setBackgroundImage(Style.cornersMask, for: .normal)
                aButton.tintColor = Style.panelBackground
                aButton.tag = aSignal.rawValue
                buttons.append(aButton)
            }
            self.buttons = buttons
            
            super.init(frame: frame)
            
            for aButton in buttons {
                aButton.addTarget(self, action: #selector(sendSignal(button:)), for: .touchUpInside)
            }
            
            contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            for aButton in self.buttons {
                self.contentView.addSubview(aButton)
            }

            contentView.addSubview(nameBackgroundView)

            nameLabel.textColor = Style.activeInformational
            nameBackgroundView.addSubview(nameLabel)
            
            connectingLabel.textColor = Style.activeInformational
            connectingLabel.font = UIFont.systemFont(ofSize: 10)
            nameBackgroundView.addSubview(connectingLabel)
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("Not implemented")
        }
        
        override func prepareForReuse() {
            nameLabel.text = nil
            state = .initial
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()

            let side = self.contentView.bounds.height
            var rightEdgeX = self.contentView.bounds.maxX
            for aButton in buttons.reversed() {
                aButton.frame = CGRect(x: rightEdgeX-side, y: 0, width: side, height: side)
                rightEdgeX -= side + 2
            }
            
            nameBackgroundView.frame = CGRect(x: 0, y: 0, width: rightEdgeX, height: side)
            nameLabel.frame = nameBackgroundView.bounds.insetBy(dx: Style.Conductor.MusiciansCollectionView.musicianNameInset, dy: 0)
            connectingLabel.frame = nameLabel.frame.offsetBy(dx: 0, dy: 16)
        }
    }
}

// MARK: Actions
extension ConductViewController.MusicianCell {
    @objc func sendSignal(button: UIButton) {
        if let handler = onSignalSelected {
            handler(Signal(rawValue: button.tag)!)
        }
    }
}

// MARK: Animations
extension ConductViewController.MusicianCell {
    func signalSentAnimation() -> CAAnimation {
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 0.3
        anim.toValue = 1.0
        anim.duration = 0.5
        anim.repeatCount = .greatestFiniteMagnitude
        return anim
    }
}
