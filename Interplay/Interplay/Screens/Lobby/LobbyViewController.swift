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
    let link: Link
    let metro: Metronome
    
    lazy var browser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: context.localPeerID, serviceType: context.serviceType)
        browser.delegate = self
        return browser
    }()
    
    var lobbyView: LobbyView {
        return view as! LobbyView
    }
    
    init(context:NetworkingContext, link: Link, metro: Metronome) {
        self.context = context
        self.link = link
        self.metro = metro
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
        requestLinkActivationIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLookingForConductor()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Ableton Link management
extension LobbyViewController {
    func requestLinkActivationIfNeeded() {
        if !link.isEnabled {
            let alert = UIAlertController(title: NSLocalizedString("Ableton Link", comment: "Ableton Link activation request alert title"), message: NSLocalizedString("Hey there! Please enable Ableton Link on the following screen. Ableton Link is the technology this app uses to play in time with other apps and devices.", comment: "Ableton Link activation request alert message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Fine, take me there", comment: "Ableton Link activation request alert action title"), style: .default, handler: { _ in
                self.present(self.link.settings, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
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
        let musicianCon = MusicianViewController(session: session, metro: metro)
        self.present(musicianCon, animated: false, completion: nil)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // ignore
    }
    
}

// MARK: Actions
extension LobbyViewController {
    @objc func becomeConductor(sender: Any?) {
        self.present(ConductViewController.navigationController(context: context, link: link), animated: false, completion: nil)
    }
}
