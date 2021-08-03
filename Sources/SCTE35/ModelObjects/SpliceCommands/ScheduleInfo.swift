//
//  ScheduleInfo.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/30/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct ScheduleInfo {
    public let events: [ScheduleEvent]
    
    init?(bits: [Bit]) {
        guard bits.count > 7 else { return nil }
        let eventsCountRange = 0...7
        let eventsCount = BitConverter.integer(fromBits: Array(bits[eventsCountRange]))

        guard bits.count > 8, eventsCount > 0 else {
            // Without a testable string and knowing its expected output, I'm torn as to
            // whether I should return nil or return a schedule info with no events
            // I am leaving this as is until then as it at least will allow my current
            // unit tests to pass
            self.events = []
            return
        }

        let remainingBitRange = 8...bits.count
        var remainingBits: [Bit] = Array(bits[remainingBitRange])
        var scheduledEvents = [ScheduleEvent]()
        for _ in 0..<eventsCount {
            guard remainingBits.count > 0 else { break }
            if let nextEvent = ScheduleEvent(bits: &remainingBits) {
                scheduledEvents.append(nextEvent)
            }
        }

        self.events = scheduledEvents
    }
}
