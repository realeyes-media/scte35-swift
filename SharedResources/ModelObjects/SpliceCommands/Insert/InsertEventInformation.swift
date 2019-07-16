//
//  InsertEventInformation.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct InsertEventInformation {
    /// A 1-bit flag that, when set to ‘1’, indicates that the splice event is an opportunity to exit from the network feed and that the value of splice_time(), as modified by pts_adjustment, shall refer to an intended Out Point or Program Out Point. When set to ‘0’, the flag indicates that the splice event is an opportunity to return to the network feed and that the value of splice_time(), as modified by pts_adjustment, shall refer to an intended In Point or Program In Point.
    public let isOutOfNetwork: Bool

    /// A 1-bit flag that, when set to ‘1’, indicates that the message refers to a Program Splice Point and that the mode is the Program Splice Mode whereby all PIDs/components of the program are to be spliced. When set to ‘0’, this field indicates that the mode is the Component Splice Mode whereby each component that is intended to be spliced will be listed separately by the syntax that follows.
    private let isProgramSpliceModeEnabled: Bool

    /// A 1-bit flag that, when set to ‘1’, indicates the presence of the break_duration() field.
    private let hasBreakDuration: Bool

    /// When this flag is ‘1’, it indicates the absence of the splice_time() field and that the splice mode shall be the Splice Immediate Mode, whereby the splicing device shall choose the nearest opportunity in the stream, relative to the splice information packet, to splice. When this flag is ‘0’, it indicates the presence of the splice_time() field in at least one location within the splice_insert() command.
    public let shouldSpliceImmediately: Bool

    public let spliceTime: SpliceTime?

    public let components: [InsertComponent]?

    /// /// The break_duration() structure specifies the duration of the commercial break(s). It may be used to give the splicer an indication of when the break will be over and when the network In Point will occur.
    public let breakDuration: BreakDuration?

    /// This value should provide a unique identification for a viewing event within the service. Note: See [SCTE 118-2] for guidance in setting values for this field. 
    public let uniqueProgramID: Int

    /// (previously ‘avail’) This field provides an identification for a specific avail within one unique_program_id. This value is expected to increment with each new avail within a viewing event. This value is expected to reset to one for the first avail in a new viewing event. This field is expected to increment for each new avail. It may optionally carry a zero value to indicate its non-usage.
    public let availableNumber: Int

    /// (previously ‘avail_count’) This field provides a count of the expected number of individual avails within the current viewing event. When this field is zero, it indicates that the avail field has no meaning.
    public let availablesExpected: Int

    init?(bits: [Bit]) {
        guard bits.count >= 40 else { return nil }
        var bits = bits
        let isOutOfNetworkLocation = 0
        self.isOutOfNetwork = bits[isOutOfNetworkLocation] == .one

        let isProgramSpliceModeEnabledLocation = 1
        self.isProgramSpliceModeEnabled = bits[isProgramSpliceModeEnabledLocation] == .one

        let hasBreakDurationLocation = 2
        self.hasBreakDuration = bits[hasBreakDurationLocation] == .one

        let shouldSpliceImmediatelyLocation = 3
        let tempShouldSpliceImmediately = bits[shouldSpliceImmediatelyLocation] == .one
        // Required due to Swift Bug SR-944 (see line 60 below)
        // https://bugs.swift.org/browse/SR-944
        self.shouldSpliceImmediately = tempShouldSpliceImmediately

        bits.removeSubrange(0..<8)

        if isProgramSpliceModeEnabled && !tempShouldSpliceImmediately {
            self.components = nil
            guard let spliceTime = SpliceTime(bits: &bits) else { return nil }
            self.spliceTime = spliceTime
        } else if !isProgramSpliceModeEnabled {
            self.spliceTime = nil
            guard bits.count >= 16 else { return nil }
            let componentCountLocation = 0..<16
            let componentCount = BitConverter.integer(fromBits: Array(bits[componentCountLocation]))
            bits.removeSubrange(componentCountLocation)

            var localComponentsArray = [InsertComponent]()
            for _ in 0..<componentCount {
                guard let component = InsertComponent(bits: &bits, shouldSpliceImmediately: shouldSpliceImmediately) else { return nil }
                localComponentsArray.append(component)
            }
            self.components = localComponentsArray
        } else {
            self.spliceTime = nil
            self.components = nil
        }

        if hasBreakDuration {
            guard bits.count >= 40 else { return nil }
            let breakDurationLocation = 0..<40
            let breakDurationBits = Array(bits[breakDurationLocation])
            bits.removeSubrange(breakDurationLocation)
            guard let breakDuration = BreakDuration(bits: breakDurationBits) else { return nil }
            self.breakDuration = breakDuration
        } else {
            self.breakDuration = nil
        }

        guard bits.count == 32 else { return nil }

        let uniqueProgramIDLocation = 0..<16
        self.uniqueProgramID = BitConverter.integer(fromBits: Array(bits[uniqueProgramIDLocation]))

        let availableNumberLocation = 16..<24
        self.availableNumber = BitConverter.integer(fromBits: Array(bits[availableNumberLocation]))

        let availablesExpectedLocation = 24..<32
        self.availablesExpected = BitConverter.integer(fromBits: Array(bits[availablesExpectedLocation]))
    }
}
