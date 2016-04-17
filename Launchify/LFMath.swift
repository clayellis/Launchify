//
//  LFMath.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// MARK: - Math
/// Progress returns a percentage value based on the progress of a value between a start and end value.
/// The progress can be clamped to those start and end values.
public func progress(value: CGFloat, start: CGFloat, end: CGFloat, clamped: Bool) -> CGFloat {
    if start >= 0 {
        let progress = (value - start) / (end - start)
        if clamped && progress < 0 {
            return 0
        } else if clamped && progress > 1 {
            return 1
        } else {
            return progress
        }
    } else {
        let progress = (value - -start) / (end - -start)
        if clamped && progress < 0 {
            return 0
        } else if clamped && progress > 1 {
            return 1
        } else {
            return progress
        }
    }
}

/// Transition returns a value between the start and end values based on the progress value (see progress(...))
public func transition(progress: CGFloat, start: CGFloat, end: CGFloat) -> CGFloat {
    return ((end - start) * progress) + start
}

/// Pivot around is an open ended pivot function
public func pivot(x: CGFloat, around: CGFloat) -> CGFloat {
    let d = around - x
    let p = x + d * 2
    return p
}

/// Pivot between is a lower and an uper limit pivot function
public func pivot(x: CGFloat, between lower: CGFloat, and upper: CGFloat, clamped: Bool) -> CGFloat {
    if clamped && x < lower {
        return upper
    } else if clamped && x > upper {
        return lower
    } else {
        return pivot(x, around: lower + ((upper - lower) / 2))
    }
}

extension Array {
    mutating func shift(sourceIndex sourceIndex: Int, destinationIndex: Int) {
        if sourceIndex < destinationIndex {
            assert(sourceIndex >= startIndex, "SourceIndex is less than 0")
            assert(destinationIndex < endIndex, "DestinationIndex is out of range")
            let prefixBlock = self[startIndex ..< sourceIndex]
            let shiftingBlock = self[(sourceIndex + 1) ... destinationIndex]
            let shiftingElement = self[sourceIndex ... sourceIndex]
            let suffixBlock = self[(destinationIndex + 1) ..< endIndex]
            self = Array(prefixBlock + shiftingBlock + shiftingElement + suffixBlock)
        } else if sourceIndex > destinationIndex {
            assert(sourceIndex < endIndex, "SourceIndex is out of range")
            assert(destinationIndex >= startIndex, "DestinationIndex is less than 0")
            let prefixBlock = self[startIndex ..< destinationIndex]
            let shiftingBlock = self[destinationIndex ..< sourceIndex]
            let shiftingElement = self[sourceIndex ... sourceIndex]
            let suffixBlock = self[(sourceIndex + 1) ..< endIndex]
            self = Array(prefixBlock + shiftingElement + shiftingBlock + suffixBlock)
        } else {
            // Do nothing
        }
    }
}