//
//  ScheduleEvent.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct ScheduleEvent {
    /// A 32-bit unique splice event identifier.
    public let id: Int

    /// A 1-bit flag that, when set to ‘1’, indicates that a previously sent splice event, identified by splice_event_id, has been cancelled.
    public let isCancelEvent: Bool

    /// Optional schedule information that should exist if passed in string is valid and cancel indicator is false
    public let info: ScheduleEventInformation?

    init?(bits: inout [Bit]) {
        guard bits.count >= 40 else { return nil }

        let idRange = 0..<32
        self.id = BitConverter.integer(fromBits: Array(bits[idRange]))

        let cancelIndicatorLocation = 32
        self.isCancelEvent = bits[cancelIndicatorLocation] == .one
        bits.removeSubrange(0..<40)

        if isCancelEvent {
            info = nil
            return
        }

        if let eventInformation = ScheduleEventInformation(bits: &bits) {
            self.info = eventInformation
        } else {
            return nil
        }
    }
}
