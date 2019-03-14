//
//  Metronome.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 5/9/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import AVFoundation
import AudioUnit

final class Metronome: NSObject {
    
    init(link: Link) throws {
        assert(linkRef == nil, "Only one instance of \(Metronome.self) may exist.")

        linkRef = link
        
        weakBeatBuffer = try Metronome.loadBuffer("Weak", ext: "wav")
        strongBeatBuffer = try Metronome.loadBuffer("Strong", ext: "wav")
        
        assert(weakBeatBuffer.format == strongBeatBuffer.format, "Both beat audio files should have the same audio format.")
        
        super.init()
        
        try setupAudioUnit()
    }
    
    func start() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        try audioSession.setActive(true)
        
        latency = AVAudioTime.hostTime(forSeconds: audioSession.outputLatency)
        
        var error: OSStatus
        error = AudioUnitInitialize(unit!)
        if error != noErr {
            throw MetronomeError.audioUnitInitFailed(error)
        }
        
        error = AudioOutputUnitStart(unit!)
        if error != noErr {
            throw MetronomeError.audioUnitStartFailed(error)
        }
    }
    
    func stop() {
        AudioOutputUnitStop(unit!)
        AudioUnitUninitialize(unit!)
        prevBeat = Int.min
        bytesToConsume = 0
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false)
    }
    
    private static func loadBuffer(_ resource: String, ext: String) throws -> AVAudioPCMBuffer {
        
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { throw MetronomeError.fileURLError(resource + "." + ext) }
        
        let file = try AVAudioFile(forReading: url)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else {
            throw MetronomeError.fileIsNotPCM(resource + "." + ext)
        }
        
        try file.read(into: buffer)
        
        return buffer
    }
    
    private var unit: AudioUnit?
    private func setupAudioUnit() throws {
        
        var outputDesc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        
        guard let output = AudioComponentFindNext(nil, &outputDesc) else {
            throw MetronomeError.findOutputFailed
        }
        
        var error = AudioComponentInstanceNew(output, &unit)
        if error != noErr {
            throw MetronomeError.createComponentFailed(error)
        }
        
        var renderCallbackStruct = AURenderCallbackStruct(inputProc: renderCallback,
                                                          inputProcRefCon: nil)
        
        error = AudioUnitSetProperty(unit!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallbackStruct, UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        if error != noErr {
            throw MetronomeError.setCallbackFailed(error)
        }
        
        let streamDescription = weakBeatBuffer.format.streamDescription
        error = AudioUnitSetProperty(unit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, streamDescription, UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        if error != noErr {
            throw MetronomeError.setStreamFormatFailed(error)
        }
    }
    
}

private let quantum = 4
private var weakBeatBuffer: AVAudioPCMBuffer!
private var strongBeatBuffer: AVAudioPCMBuffer!
private var latency = UInt64(0)
private var linkRef: Link!
private var offs = UInt32(0)
private var bytesToConsume = UInt32(0)
private var prevBeat = Int.min

private func clearBuffers(_ ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    guard let outBufferList = UnsafeMutableAudioBufferListPointer(ioData) else { return noErr }
    for aBuffer in outBufferList {
        memset(aBuffer.mData, 0, Int(aBuffer.mDataByteSize))
    }
    return noErr
}

private func renderCallback(inRefCon: UnsafeMutableRawPointer,
                            ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                            inTimeStamp: UnsafePointer<AudioTimeStamp>,
                            inBusNumber: UInt32,
                            inNumberFrames: UInt32,
                            ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    
    let bufferHostTime = inTimeStamp.pointee.mHostTime + latency
    let beat = linkRef.beat(atHostTime: bufferHostTime, quantum: Double(quantum))
    let wholeBeat = Int(floor(beat))
    let isStrong = wholeBeat % quantum == 0
    
    let inBufferList = UnsafeMutableAudioBufferListPointer(isStrong ? strongBeatBuffer.mutableAudioBufferList : weakBeatBuffer.mutableAudioBufferList)
    
    // skip until the next beat
    if prevBeat == Int.min {
        prevBeat = wholeBeat
        return clearBuffers(ioData)
    }

    // next beat, start playing
    if wholeBeat != prevBeat {
        prevBeat = wholeBeat
        bytesToConsume = inBufferList[0].mDataByteSize
        offs = 0
    }
    
    if bytesToConsume == 0 {
        // nothing to do, return
        return clearBuffers(ioData)
    }
    
    guard let outBufferList = UnsafeMutableAudioBufferListPointer(ioData) else { return noErr }
    
    let inBufferSize = inBufferList[0].mDataByteSize
    let outBufferSize = outBufferList[0].mDataByteSize
    let bytesLeftToCopy = min(outBufferSize, bytesToConsume)
    bytesToConsume -= bytesLeftToCopy

    for bufferIdx in 0..<outBufferList.count {
        let inBuffer = inBufferList[bufferIdx]
        let outBuffer = outBufferList[bufferIdx]
        let sz = min(bytesLeftToCopy, inBufferSize - offs)
        memcpy(outBuffer.mData, inBuffer.mData?.advanced(by: Int(offs)), Int(sz))
        // copy the leftovers
        if sz < bytesLeftToCopy {
            memcpy(outBuffer.mData?.advanced(by: Int(sz)), inBuffer.mData, Int(bytesLeftToCopy - sz))
        }
    }
    
    offs += bytesLeftToCopy
    offs %= inBufferSize
    
    return noErr
}

enum MetronomeError: LocalizedError {
    case findOutputFailed
    case createComponentFailed(OSStatus)
    case setCallbackFailed(OSStatus)
    case setStreamFormatFailed(OSStatus)
    case audioUnitInitFailed(OSStatus)
    case audioUnitStartFailed(OSStatus)
    case fileURLError(String)
    case fileIsNotPCM(String)
    
    var errorDescription: String? {
        switch self {
            
        case .findOutputFailed:
            return NSLocalizedString("Metronome failed to find a suitable audio output.", comment: "MetronomeError.findOutputFailed")
            
        case .createComponentFailed(let os),
             .setCallbackFailed(let os),
             .setStreamFormatFailed(let os),
             .audioUnitInitFailed(let os),
             .audioUnitStartFailed(let os):
            return NSLocalizedString("Metronome audio operation error, OSStatus = \(os)", comment: "Metronome OSStatus error.")
            
        case .fileURLError(let resource):
            return NSLocalizedString("Metronome failed to locate \"\(resource)\".", comment: "MetronomeError.fileURLError")
            
        case .fileIsNotPCM(let resource):
            return NSLocalizedString("Metronome failed to load \"\(resource)\" because the file is not in a PCM format.", comment: "MetronomeError.fileIsNotPCM")

        }
    }
}
