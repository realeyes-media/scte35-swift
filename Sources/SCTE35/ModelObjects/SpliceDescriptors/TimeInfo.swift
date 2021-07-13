//
//  TimeInfo.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 6/5/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// The time_descriptor is an implementation of a splice_descriptor. It provides an optional extension to the splice_insert(), splice_null() and time_signal() commands that allows a programmer’s wall clock time to be sent to a client. For the highest accuracy, this descriptor should be used with a time_signal() or splice_insert() command that has the time_specified_flag equal to 1. This command may be inserted using SCTE 104 or by out of band provisioning on the device inserting this message.

/// The repetition rate of this descriptor should be at least once every 5 seconds. When it is the only descriptor present in the time_signal() or splice_null() command, then the encoder should not insert a key frame.

/// This command may be used to synchronize time based external metadata with video and the party responsible for the metadata and the time value used should insure that they are properly synchronized and have the desired level of accuracy required for their application.
public struct TimeInfo: SpliceDescriptorInfo {
    /// This 8-bit number defines the syntax for the private bytes that make up the body of this descriptor. The splice_descriptor_tag shall have a value of 0x03.
    public let tag: Int

    /// This 8-bit number gives the length, in bytes, of the descriptor following this field. The descriptor_length field shall have a value of 0x10.
    public let length: Int

    /// This 32-bit number is used to identify the owner of the descriptor. The identifier shall have a value of 0x43554549 (ASCII “CUEI”).
    public let identifier: Int

    /// This 48-bit number is the TAI seconds value.
    public let taiSeconds: Int

    /// This 32-bit number is the TAI nanoseconds value.
    public let taiNS: Int

    /// This 16-bit number shall be used in the conversion from TAI time to UTC or NTP time per the following equations:

    /// UTC seconds = TAI seconds - UTC_offset;
    /// NTP seconds = TAI seconds - UTC_offset + 2,208,988,800
    public let utcOffset: Int

    init?(tag: Int, length: Int, relevantBits: [Bit]) {
        guard tag == 0x03 else { return nil }
        self.tag = tag
        guard length == 0x10 else { return nil }
        self.length = length
        guard relevantBits.count == 128 else { return nil }

        let identifierRange = 0..<32
        self.identifier = BitConverter.integer(fromBits: Array(relevantBits[identifierRange]))
        let taiSecondsRange = 32..<80
        self.taiSeconds = BitConverter.integer(fromBits: Array(relevantBits[taiSecondsRange]))
        let taiNSRange = 80..<112
        self.taiNS = BitConverter.integer(fromBits: Array(relevantBits[taiNSRange]))
        let utcOffsetRange = 112..<128
        self.utcOffset = BitConverter.integer(fromBits: Array(relevantBits[utcOffsetRange]))
    }
}
