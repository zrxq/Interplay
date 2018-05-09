//
//  MusicianViewController.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: UIViewController
class MusicianViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    let session: MCSession
    let metro: Metronome
    
    init(session: MCSession, metro: Metronome) {
        self.session = session
        self.metro = metro
        super.init(nibName: nil, bundle: nil)
        session.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var musicianView: MusicianView {
        return view as! MusicianView
    }
    
    override func loadView() {
        view = MusicianView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicianView.nameField.text = UserDefaults.musicianName ?? session.myPeerID.displayName
        musicianView.nameField.delegate = self
        
        musicianView.reconnectButton.addTarget(self, action: #selector(dismiss as ()->Void), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.musicianName == nil {
            musicianView.nameField.becomeFirstResponder()
        }
        metro.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        metro.stop()
    }
    
}

// MARK: MCSessionDelegate
extension MusicianViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {[weak self] () in
            do {
                let packet = try Packet.decoder.decode(Packet.self, from: data)
                switch packet {
                case .signal(let sig):
                    self?.musicianView.signal = sig
                    let data = try Packet.encoder.encode(packet)
                    // send ack
                    try session.send(data, toPeers: [peerID, ], with: .reliable)
                default:
                    print("Don't know how to handle packet type \(packet)")
                }
            }
            catch let error {
                fatalError(error.localizedDescription)
                // TODO: ...
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                self.dismiss()
            case .connected:
                if let musicianName = UserDefaults.musicianName {
                    if  session.myPeerID.displayName != musicianName {
                        self.send(name: musicianName)
                    }
                }
            default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError("Unexpected stream \"\(streamName)\"")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("Unexpected resource \"\(resourceName)\"")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("What the actual fuck?")
    }
    
}

// MARK: Network operations
extension MusicianViewController {
    func send(packet: Packet) {
        do {
            if let remotePeerID = session.connectedPeers.first {
                let data = try Packet.encoder.encode(packet)
                try session.send(data, toPeers: [remotePeerID, ], with: .reliable)
            }
        }
        catch let e {
            handle(error: e)
        }
    }
    
    func send(name: String) {
        send(packet: Packet.name(name))
    }
}

extension MusicianViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.musicianView.namePromptLabel.alpha = 1
        }
        UserDefaults.musicianName = textField.text
        if textField.text == nil {
            textField.text = session.myPeerID.displayName
        }
        send(name: textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.musicianView.namePromptLabel.alpha = 0
        }
    }
}

// MARK: Actions
extension MusicianViewController {
    @objc func dismiss() {
        session.disconnect()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Error handling
extension MusicianViewController {
    func handle(error: Error) {
        let errorAlert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Musician, Error alert, okay button title"), style: .default, handler: nil))
        self.present(errorAlert, animated: true, completion: nil)
    }
}

