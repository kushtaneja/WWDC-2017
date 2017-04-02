// 
//  Twist.swift
//
//  Created by Kush Taneja
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import AVFoundation

/**
 An enum of different twists that can be applied.
 These can be pitch, speed, and volume.
 */
public enum TwistType {
    case pitch, speed, volume
    
    // The range that the particular modifier can be between.
    var twistRange: ClosedRange<Float> {
        switch self {
        case .pitch:
            return 0.5 ... 2.0
        case .speed:
            return 0.1 ... 2.0
        case .volume:
            return 0.0 ... 1.0
        }
    }
}

/// This class provides effects to twist how the speech sounds.
public struct Twist {
    
    var type: TwistType
    
    private var valueRange: ClosedRange<Int>

    public init(type: TwistType, effectFrom startValue: Int, to endValue: Int) {
        self.type = type
        
        let firstValue = startValue.snapped(to: Constants.userValueRange)
        let secondValue = endValue.snapped(to: Constants.userValueRange)
        if firstValue < secondValue {
            self.valueRange = firstValue...secondValue
        } else {
            self.valueRange = secondValue...firstValue
        }
    }

    func twistValue(fromNormalizedValue normalizedValue: CGFloat) -> Float {
        let valueRangeCount = CGFloat(valueRange.count)
        let normalizedValueInDefinedRange = ((normalizedValue * valueRangeCount) + CGFloat(valueRange.lowerBound)) / CGFloat(Constants.userValueRange.count)
        
        return Twist.twist(normalizedValue: normalizedValueInDefinedRange, forType: type)
    }
    
    public static func twist(normalizedValue: CGFloat, forType type: TwistType) -> Float {
        let twistRange = type.twistRange
        return (Float(normalizedValue) * (twistRange.upperBound - twistRange.lowerBound)) + twistRange.lowerBound
    }
}

