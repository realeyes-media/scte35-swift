//
//  BreakDuration.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct BreakDuration {
    /// A 1-bit flag that, when set to ‘1’, denotes that the duration shall be used by the splicing device to know when the return to the network feed (end of break) is to take place. A splice_insert() command with out_of_network_indicator set to 0 is not intended to be sent to end this break. When this flag is ‘0’, the duration field, if present, is not required to end the break because a new splice_insert() command will be sent to end the break. In this case, the presence of the break_duration field acts as a safety mechanism in the event that a splice_insert() command is lost at the end of a break.
    public let autoReturn: Bool

    /// A 33-bit field that indicates elapsed time in terms of ticks of the program’s 90 kHz clock.
    public let duration: Int

    init?(bits: [Bit]) {
        guard bits.count == 40 else { return nil }

        let autoReturnLocation = 0
        self.autoReturn = bits[autoReturnLocation] == .one

        let durationLocation = 7..<40
        self.duration = BitConverter.integer(fromBits: Array(bits[durationLocation]))
    }
}
