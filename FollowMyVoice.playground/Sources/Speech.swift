//
//  Speech.swift
//
//  Created by Kush Taneja
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import AVFoundation

public struct SnappedInteger {
    private let range: ClosedRange<Int>
    private var _integer: Int
    
    var snapped: Int {
        set {
            _integer = newValue.snapped(to: range)
        }
        get {
            return _integer
        }
    }
    
    init(_ integer: Int, in range: ClosedRange<Int>) {
        self.range = range
        self._integer = integer.snapped(to: range)
    }
}

struct Constants {
    static let userValueRange: ClosedRange<Int> = 0...150
    
    static var maxUserValue: Int {
        return userValueRange.upperBound
    }
}

/// A speech class that can speak various words and have filters and effects applied to the speech.
public class Speech: NSObject{
    
    private var _defaultVolume = SnappedInteger(snappedUserValueWithDefaultOf: 5)
    public var defaultVolume: Int {
        get { return _defaultVolume.snapped }
        set { _defaultVolume.snapped = newValue }
    }
    
    public var normalizedVolume: CGFloat {
        return CGFloat(defaultVolume) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultSpeed = SnappedInteger(snappedUserValueWithDefaultOf: 30)
    public var defaultSpeed: Int {
        get { return _defaultSpeed.snapped }
        set { _defaultSpeed.snapped = newValue }
    }
    
    public var normalizedSpeed: CGFloat {
        return CGFloat(defaultSpeed) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultPitch = SnappedInteger(snappedUserValueWithDefaultOf: 33)
    public var defaultPitch: Int {
        get { return _defaultPitch.snapped }
        set { _defaultPitch.snapped = newValue }
    }
    
    public var normalizedPitch: CGFloat {
        return CGFloat(defaultPitch) / CGFloat(Constants.maxUserValue)
    }
    
    // MARK: Private Properties
    public var speechSynthesizer = AVSpeechSynthesizer()
    // MARK: Initializers
    
    public override init() {
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print("Error: Could not set audio category: \(error), \(error.userInfo)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error: Could not setActive to true: \(error), \(error.userInfo)")
        }
    }

    public func speak(_ text: String, rate: Float = 0.6, pitchMultiplier: Float = 1.0, volume: Float = 1.0) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.volume = volume
        utterance.pitchMultiplier = pitchMultiplier
        speechSynthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .word)
    }
    public func isSpeaking()->Bool{
        return speechSynthesizer.isSpeaking
    }
    public func pauseSpeaking(){
        speechSynthesizer.pauseSpeaking(at: .immediate)
    }
    public func continueSpeaking(){
        speechSynthesizer.continueSpeaking()
    }
}

extension Int {
    func snapped(to range: ClosedRange<Int>) -> Int {
        return snapped(min: range.lowerBound, max: range.upperBound)
    }
    
    func snapped(min: Int, max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}

extension SnappedInteger {
    init(snappedUserValueWithDefaultOf integer: Int) {
        self.init(integer, in: Constants.userValueRange)
    }
}

