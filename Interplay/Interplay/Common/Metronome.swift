//
//  Metronome.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 5/9/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import AVFoundation

class Metronome: NSObject {
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    
    let weakBeat: AVAudioFile
    let strongBeat: AVAudioFile
    
    var beat = Int(0)
    let link: Link
    
    let quantum = 4

    init(link: Link) {
        
        self.link = link

        do {
            weakBeat = try AVAudioFile(forReading: Bundle.main.url(forResource: "Weak", withExtension: "wav")!)
            strongBeat = try AVAudioFile(forReading: Bundle.main.url(forResource: "Strong", withExtension: "wav")!)
        }
        catch let e {
            fatalError(e.localizedDescription)
        }
        
        super.init()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        let output: AVAudioOutputNode = engine.outputNode
        engine.attach(player)
        engine.connect(player, to: output, fromBus: 0, toBus: 0, format: format)
    }
    
    func scheduleBeats() {
        link.captureTimeline(from: .audio) { (timeLine) in
            let latencyHostTicks: UInt64 =  AVAudioTime.hostTime(forSeconds: self.engine.outputNode.presentationLatency)
            let time = AVAudioTime(hostTime: timeLine.hostTime(atBeat: Double(self.beat), quantum: Double(self.quantum)) - latencyHostTicks)
            
            let strong = self.beat % self.quantum == 0
            self.player.scheduleFile(strong ? self.strongBeat : self.weakBeat, at: time) {
                self.beat = self.beat + 1
                self.scheduleBeats()
            }
        }
    }

    deinit {
        engine.detach(player)
    }
    
    func start() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryAmbient)
            try audioSession.setActive(true)
            try engine.start()
            player.play()
            scheduleBeats()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func stop() {
        player.stop()
        player.reset()
        engine.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false)
    }
    
}
