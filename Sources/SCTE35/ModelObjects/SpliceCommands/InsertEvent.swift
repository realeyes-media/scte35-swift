//
//  InsertEvent.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct InsertEvent {
    /// A 32-bit unique splice event identifier.
    public let id: Int
    /// A 1-bit flag that, when set to ‘1’, indicates that a previously sent splice event, identified by splice_event_id, has been cancelled.
    public let isCancelEvent: Bool
    /// Optional event information that should exist if passed in string is valid and cancel indicator is false
    public let info: InsertEventInformation?

    /// - Throws: An error of type `SCTE35ParsingError`
    init(bits: [Bit]) throws {
        guard bits.count >= 40 else { throw SCTE35ParsingError.unableToCreateSpliceCommand(type: CommandType.insert) }
        let idRange = 0..<32
        self.id = BitConverter.integer(fromBits: Array(bits[idRange]))

        let eventCancelLocation = 32
        self.isCancelEvent = bits[eventCancelLocation] == .one

        if isCancelEvent {
            info = nil
        } else {
            guard bits.count > 40 else {
                throw SCTE35ParsingError.unableToCreateSpliceCommand(type: CommandType.insert)
            }
            let rangeOfInsertEventInformation = 40..<bits.count
            let insertEventInformationBits = Array(bits[rangeOfInsertEventInformation])
                        self.info = InsertEventInformation(bits: insertEventInformationBits)

        }
    }
}
