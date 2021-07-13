//
//  DTMFInfo.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 6/4/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// The DTMF_descriptor() is an implementation of a splice_descriptor. It provides an optional extension to the splice_insert() command that allows a receiver device to generate a legacy analog DTMF sequence based on a splice_info_section being received.
public struct DTMFInfo: SpliceDescriptorInfo {
    /// This 8-bit number defines the syntax for the private bytes that make up the body of this descriptor. The splice_descriptor_tag shall have a value of 0x01.
    public let tag: Int

    /// This 8-bit number gives the length, in bytes, of the descriptor following this field.
    public let length: Int

    /// This 32-bit number is used to identify the owner of the descriptor. The identifier shall have a value of 0x43554549 (ASCII “CUEI”).
    public let identifier: Int

    /// This 8-bit number is the time the DTMF is presented to the analog output of the device in tenths of seconds. This gives a pre-roll range of 0 to 25.5 seconds. The splice info section shall be sent at least two seconds earlier then this value. The minimum suggested pre-roll is 4.0 seconds.
    public let preroll: Int

    /// This value of this flag is the number of DTMF characters the device is to generate.
    public let dtmfCount: Int

    /// This is an ASCII value for the numerals ‘0’ to ‘9’, ‘*’, ‘#’. The device shall use these values to generate a DTMF sequence to be output on an analog output. The sequence shall complete with the last character sent being the timing mark for the pre-roll.
    public let dtmfChars: String

    init?(tag: Int, length: Int, relevantBits: [Bit]) {
        guard tag == 0x01 else { return nil }
        self.tag = tag
        guard length == (relevantBits.count / 8) else { return nil }
        self.length = length
        guard relevantBits.count >= 64 else { return nil }

        var bits = relevantBits
        let idRange = 0..<32
        let prerollRange = 32..<40
        let dtmfCountRange = 40..<43

        self.identifier = BitConverter.integer(fromBits: Array(bits[idRange]))
        guard self.identifier == 0x43554549 else { return nil }
        self.preroll = BitConverter.integer(fromBits: Array(bits[prerollRange]))
        self.dtmfCount = BitConverter.integer(fromBits: Array(bits[dtmfCountRange]))

        let rangeToRemove = 0..<48
        bits.removeSubrange(rangeToRemove)

        var dtmfChars: String = ""
        for _ in 0..<self.dtmfCount {
            guard bits.count >= 8 else { return nil }
            let asciiValueRange = 0..<8
            let asciiBits = Array(bits[asciiValueRange])
            let asciiValue = BitConverter.integer(fromBits: asciiBits)
            let character = String(UnicodeScalar(UInt8(asciiValue)))
            dtmfChars += character

            bits.removeSubrange(asciiValueRange)
        }
        self.dtmfChars = dtmfChars
    }
}
