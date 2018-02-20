//
//  LobbyViewController.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/13/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: UIViewController
class LobbyViewController: UIViewController {
    
    #if DEBUG
    static let timeIntervalBeforeConductingEnabled: TimeInterval = 1
    #else
    static let timeIntervalBeforeConductingEnabled: TimeInterval = Const.delayInSecondsBeforeConductingEnabled
    #endif
    
    let context: NetworkingContext
    
    lazy var browser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: context.localPeerID, serviceType: context.serviceType)
        browser.delegate = self
        return browser
    }()
    
    var lobbyView: LobbyView {
        return view as! LobbyView
    }
    
    init(with context:NetworkingContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented.")
    }
    
    override func loadView() {
        view = LobbyView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lobbyView.conductButton.addTarget(self, action: #selector(becomeConductor(sender:)), for: .touchUpInside)
    }
    
    func startLookingForConductor() {
        browser.startBrowsingForPeers()
        lobbyView.spinner.startAnimating()
        lobbyView.enableConductButton(after: LobbyViewController.timeIntervalBeforeConductingEnabled)
    }
    
    func stopLookingForConductor() {
        browser.stopBrowsingForPeers()
        lobbyView.spinner.stopAnimating()
        lobbyView.disableConductButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLookingForConductor()
        view.setNeedsLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLookingForConductor()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: MCNearbyServiceBrowserDelegate
extension LobbyViewController: MCNearbyServiceBrowserDelegate  {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        stopLookingForConductor()
        let errorCon = UIAlertController(title: NSLocalizedString("Couldn't start looking for a host", comment: "Lobby view controller browsing for peers failed"), message: error.localizedDescription, preferredStyle: .alert)
        let retry = UIAlertAction(title: NSLocalizedString("Retry", comment: "Alert action, try again"), style: .default) { (_) in
            self.startLookingForConductor()
        }
        errorCon.addAction(retry)
        self.present(errorCon, animated: true, completion: nil)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer remotePeerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let session = MCSession(peer: context.localPeerID, securityIdentity: nil, encryptionPreference: .none)
        browser.invitePeer(remotePeerID, to: session, withContext: nil, timeout: 3)
        let musicianCon = MusicianViewController(session: session)
        self.present(musicianCon, animated: false, completion: nil)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // ignore
    }
    
}

// MARK: Actions
extension LobbyViewController {
    @objc func becomeConductor(sender: Any?) {
        let conductorCon = ConductViewController(with: context)
        self.present(conductorCon, animated: false, completion: nil)
    }
}
