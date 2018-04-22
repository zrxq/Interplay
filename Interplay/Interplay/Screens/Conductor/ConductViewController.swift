//
//  ConductViewController.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: UIViewController
class ConductViewController: UIViewController {
    
    // networking
    let context: NetworkingContext
    let session: MCSession
    
    // link
    let link: Link
    var tempoDisplay: TempoDisplay
    
    // models
    var musicians = [Musician]()
    
    // views
    let conductView = ConductView(frame: .zero)
    let musicianCellIdentifier = "jamgym.interplay.musician-cell"
    
    lazy var advertiser: MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(peer: context.localPeerID, discoveryInfo: nil, serviceType: context.serviceType)
        advertiser.delegate = self
        return advertiser
    }()
    
    init(context: NetworkingContext, link: Link, tempoDisplay: TempoDisplay) {
        // networking
        self.context = context
        session = MCSession(peer: context.localPeerID, securityIdentity: nil, encryptionPreference: .none)

        // Link
        self.link = link
        self.tempoDisplay = tempoDisplay
        
        super.init(nibName: nil, bundle: nil)
        
        // networking
        session.delegate = self
        
        // collection view / flow layout / cells
        conductView.musiciansCollectionView.register(MusicianCell.self, forCellWithReuseIdentifier: musicianCellIdentifier)
        conductView.musiciansCollectionView.dataSource = self
        if #available(iOS 11.0, *) {
            conductView.musiciansCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        edgesForExtendedLayout = UIRectEdge()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func loadView() {
        self.view = conductView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLookingForMusicians()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLookingForMusicians()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: Notification.Name.TJGLinkTempoDidChange, object: nil, queue: OperationQueue.main) { note in
            if let newTempo = note.userInfo?[TJGTempoUserInfoKey] as? Double {
                self.tempoDisplay.bpm = newTempo
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Data Source
extension ConductViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicians.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: musicianCellIdentifier, for: indexPath) as! MusicianCell
        let model = musicians[indexPath.row]
        cell.state = model.state
        cell.name = model.name
        
        let peerID = self.peerID(for: indexPath.row)
        cell.onSignalSelected = { (signal) in
            self.send(signal: signal, peerID: peerID)
        }
        return cell
    }
}

// MARK: Musicians UI
extension ConductViewController {
    
    func indexPath(for index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
    
    func peerID(for index: Int) -> MCPeerID {
        return musicians[index].peerID
    }
    
    func index(peerID: MCPeerID) -> Int? {
        return musicians.index{ $0.peerID == peerID }
    }
    
    func addMusician(peerID: MCPeerID) {
        if index(peerID: peerID) != nil {
            return
        }
        musicians.append(Musician(with: peerID))
        conductView.musiciansCollectionView.insertItems(at: [indexPath(for: musicians.count - 1), ])
    }
    
    func removeMusician(peerID: MCPeerID) {
        let idx = index(peerID: peerID)!
        musicians.remove(at: idx)
        conductView.musiciansCollectionView.deleteItems(at: [indexPath(for: idx), ])
    }
    
    func setState(state:Musician.State, peerID:MCPeerID) {
        let idx = index(peerID: peerID)!
        musicians[idx].state = state
        conductView.musiciansCollectionView.reloadItems(at: [indexPath(for: idx), ])
    }
    
}

// MARK: Musicians API
extension ConductViewController {
    static let commFailure = NSLocalizedString("Communication failure", comment: "Conduct, Network error title")
    static let encoder = JSONEncoder()
    
    func send(packet: Packet, peerID: MCPeerID) {
        do {
            try session.send(try Packet.encoder.encode(packet), toPeers: [peerID, ], with: .reliable)
        }
        catch let error {
            handle(error: error, failure: ConductViewController.commFailure, peerID: peerID)
        }
    }
    
    func send(signal: Signal, peerID: MCPeerID) {
        setState(state: .signalSending(signal), peerID: peerID)
        send(packet: Packet.signal(signal), peerID: peerID)
    }
    
}

// MARK: Discovery, MCNearbyServiceAdvertiserDelegate
extension ConductViewController: MCNearbyServiceAdvertiserDelegate {
    func startLookingForMusicians() {
        advertiser.startAdvertisingPeer()
    }
    
    func stopLookingForMusicians() {
        advertiser.stopAdvertisingPeer()
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        stopLookingForMusicians()
        let errorCon = UIAlertController(title: NSLocalizedString("Couldn't start looking for musicians", comment: "Conduct view controller advertising peer failed"), message: error.localizedDescription, preferredStyle: .alert)
        let retry = UIAlertAction(title: NSLocalizedString("Retry", comment: "Alert action, try again"), style: .default) { (_) in
            self.startLookingForMusicians()
        }
        errorCon.addAction(retry)
        self.present(errorCon, animated: true, completion: nil)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if session.connectedPeers.count > Const.maximumNamberOfMusiciansPerConductor {
            invitationHandler(false, nil)
            return
        }
        invitationHandler(true, session)
        addMusician(peerID: peerID)
    }
}

// MARK: MCSessionDelegate
extension ConductViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            do {
                let packet = try Packet.decoder.decode(Packet.self, from: data)
                switch packet {
                case .signal(let sig):
                    self.setState(state: .signalConfirmed(sig), peerID: peerID)
                    
                case .name(let newName):
                    if let idx = self.index(peerID: peerID) {
                        self.musicians[idx].name = newName
                        self.conductView.musiciansCollectionView.reloadItems(at: [self.indexPath(for: idx), ])
                    }
                }
            }
            catch let error {
                self.handle(error: error, failure: ConductViewController.commFailure, peerID: peerID)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                self.removeMusician(peerID: peerID)
            case .connecting:
                self.setState(state: .connecting, peerID: peerID)
            case .connected:
                self.send(signal: Signal.stop, peerID: peerID)
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

// MARK: Error handling
// (kinda rudimentary for now ehehe)
extension ConductViewController {
    func handle(error: Error, failure: String, peerID: MCPeerID) {
        self.setState(state: .failure(error), peerID: peerID)
        let errorAlert = UIAlertController(title: failure, message: error.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Conduct, Error alert, okay button title"), style: .default, handler: nil))
        self.present(errorAlert, animated: true, completion: nil)
    }
}
