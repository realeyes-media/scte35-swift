//
//  SpliceTime.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct SpliceTime {
    public let isTimeSpecified: Bool
    public let ptsTime: Int?

    init?(bits: inout [Bit]) {
        guard !bits.isEmpty else { return nil }
        let isTimeSpecifiedLocation = 0
        isTimeSpecified = bits[isTimeSpecifiedLocation] == .one

        if isTimeSpecified {
            guard bits.count >= 40 else { return nil }
            let ptsTimeRange = 7..<40
            ptsTime = BitConverter.integer(fromBits: Array(bits[ptsTimeRange]))
            bits.removeSubrange(0..<40)
        } else {
            guard bits.count >= 8 else { return nil }
            ptsTime = nil
            bits.removeSubrange(0..<8)
        }
    }
}
