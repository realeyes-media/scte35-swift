//
//  ScheduleComponent.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct ScheduleComponent {
    /// An 8-bit value that identifies the elementary PID stream containing the Splice Point specified by the value of splice_time() that follows. The value shall be the same as the value used in the stream_identifier_descriptor() to identify that elementary PID stream.
    public let tag: Int

    /// A 32-bit unsigned integer quantity representing the time of the signaled splice event as the number of seconds since 00 hours UTC, January 6th, 1980, with the count of intervening leap seconds included. The utc_splice_time may be converted to UTC without the use of the GPS_UTC_offset value provided by the System Time table. The utc_splice_time field is used only in the splice_schedule() command.
    public let utcSpliceTime: Int

    init?(bits: [Bit]) {
        guard bits.count == 40 else { return nil }

        let tagRange = 0..<8
        self.tag = BitConverter.integer(fromBits: Array(bits[tagRange]))

        let durationLocation = 8..<40
        self.utcSpliceTime = BitConverter.integer(fromBits: Array(bits[durationLocation]))
    }
}
