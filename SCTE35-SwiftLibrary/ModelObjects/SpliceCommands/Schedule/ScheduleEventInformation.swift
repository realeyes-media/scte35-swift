//
//  ScheduleEventInformation.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct ScheduleEventInformation {
    /// A 1-bit flag that, when set to ‘1’, indicates that the splice event is an opportunity to exit from the network feed and that the value of utc_splice_time shall refer to an intended Out Point or Program Out Point. When set to ‘0’, the flag indicates that the splice event is an opportunity to return to the network feed and that the value of utc_splice_time shall refer to an intended In Point or Program In Point.
    public let isOutOfNetwork: Bool

    /// A 1-bit flag that, when set to ‘1’, indicates that the message refers to a Program Splice Point and that the mode is the Program Splice Mode whereby all PIDs/components of the program are to be spliced. When set to ‘0’, this field indicates that the mode is the Component Splice Mode whereby each component that is intended to be spliced will be listed separately by the syntax that follows.
    private let isProgramSpliceModeEnabled: Bool

    /// A 1-bit flag that indicates the presence of the break_duration() field.
    private let hasBreakDuration: Bool

    /// A 32-bit unsigned integer quantity representing the time of the signaled splice event as the number of seconds since 00 hours UTC, January 6th, 1980, with the count of intervening leap seconds included. The utc_splice_time may be converted to UTC without the use of the GPS_UTC_offset value provided by the System Time table. The utc_splice_time field is used only in the splice_schedule() command.
    public let utcSpliceTime: Int?

    /// Components are equivalent to elementary PID streams. If program_splice_flag == ‘0’ then the value of component_count shall be greater than or equal to 1.
    public let components: [ScheduleComponent]?

    /// The break_duration() structure specifies the duration of the commercial break(s). It may be used to give the splicer an indication of when the break will be over and when the network In Point will occur.
    public let breakDuration: BreakDuration?

    /// This value should provide a unique identification for a viewing event within the service.
    public let uniqueProgramID: Int

    /// This field provides an identification for a specific avail within one unique_program_id. This value is expected to increment with each new avail within a viewing event. This value is expected to reset to one for the first avail in a new viewing event. This field is expected to increment for each new avail. It may optionally carry a zero value to indicate its non-usage.
    public let availableNumber: Int

    /// This field provides a count of the expected number of individual avails within the current viewing event. When this field is zero, it indicates that the avail_num field has no meaning.
    public let availablesExpected: Int

    init?(bits: inout [Bit]) {
        guard bits.count > 8 else { return nil }
        let outOfNetworkLocation = 0
        self.isOutOfNetwork = bits[outOfNetworkLocation] == .one

        let programSpliceFlagLocation = 1
        self.isProgramSpliceModeEnabled = bits[programSpliceFlagLocation] == .one

        let hasBreakDurationLocation = 2
        self.hasBreakDuration = bits[hasBreakDurationLocation] == .one

        bits.removeSubrange(0..<8)

        if isProgramSpliceModeEnabled {
            self.components = nil
            guard bits.count >= 32 else { return nil }
            let utcSpliceTimeRange = 0..<32
            self.utcSpliceTime = BitConverter.integer(fromBits: Array(bits[utcSpliceTimeRange]))
            bits.removeSubrange(utcSpliceTimeRange)
        } else {
            self.utcSpliceTime = nil
            guard bits.count >= 8 else { return nil }
            let componentCountRange = 0..<8
            let componentCount = BitConverter.integer(fromBits: Array(bits[componentCountRange]))
            bits.removeSubrange(componentCountRange)
            var components = [ScheduleComponent]()
            for _ in 0..<componentCount {
                guard bits.count >= 40 else { return nil }
                let rangeOfNextComponentsBits = 0..<40
                let componentBits = Array(bits[rangeOfNextComponentsBits])
                if let nextComponent = ScheduleComponent(bits: componentBits) {
                    components.append(nextComponent)
                }
                bits.removeSubrange(rangeOfNextComponentsBits)
            }
            self.components = components
        }

        if hasBreakDuration {
            guard bits.count >= 40 else { return nil }
            let breakDurationRange = 0..<40
            let breakDurationBits = Array(bits[breakDurationRange])
            breakDuration = BreakDuration(bits: breakDurationBits)
            bits.removeSubrange(breakDurationRange)
        } else {
            breakDuration = nil
        }

        guard bits.count >= 24 else { return nil }

        let uniqueProgramIDRange = 0..<16
        self.uniqueProgramID = BitConverter.integer(fromBits: Array(bits[uniqueProgramIDRange]))

        let availableNumberRange = 16..<24
        self.availableNumber = BitConverter.integer(fromBits: Array(bits[availableNumberRange]))

        let availablesExpectedRange = 24..<32
        self.availablesExpected = BitConverter.integer(fromBits: Array(bits[availablesExpectedRange]))
    }
}
