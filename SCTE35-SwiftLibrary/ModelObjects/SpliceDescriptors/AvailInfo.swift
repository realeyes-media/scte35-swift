//
//  AvailInfo.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 6/3/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// The avail_descriptor is an implementation of a splice_descriptor. It provides an optional extension to the splice_insert() command that allows an authorization identifier to be sent for an avail. Multiple copies of this descriptor may be included by using the loop mechanism provided. This identifier is intended to replicate the functionality of the cue tone system used in analog systems for ad insertion. This descriptor is intended only for use with a splice_insert() command, within a splice_info_section.
public struct AvailInfo: SpliceDescriptorInfo {
    /// This 8-bit number defines the syntax for the private bytes that make up the body of this descriptor. The splice_descriptor_tag shall have a value of 0x00.
    public let tag: Int

    /// This 8-bit number gives the length, in bytes, of the descriptor following this field. The descriptor_length field shall have a value of 0x08.
    public let length: Int

    /// This 32-bit number is used to identify the owner of the descriptor. The identifier shall have a value of 0x43554549 (ASCII “CUEI”).
    public let identifier: Int

    /// This 32-bit number provides information that a receiving device may utilize to alter its behavior during or outside of an avail. It may be used in a manner similar to analog cue tones. An example would be a network directing an affiliate or a head-end to black out a sporting event.
    public let providerAvailID: Int

    init?(tag: Int, length: Int, relevantBits: [Bit]) {
        guard tag == 0x00 else { return nil }
        self.tag = tag
        guard length == 0x08 else { return nil }
        self.length = length
        guard relevantBits.count == 64 else { return nil }
        
        let idRange = 0..<32
        let providerAvailRange = 32..<64

        self.identifier = BitConverter.integer(fromBits: Array(relevantBits[idRange]))
        guard self.identifier == 0x43554549 else { return nil }
        self.providerAvailID = BitConverter.integer(fromBits: Array(relevantBits[providerAvailRange]))
    }
}
