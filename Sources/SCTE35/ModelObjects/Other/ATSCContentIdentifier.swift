//
//  ATSCContentIdentifier.swift
//  
//
//  Created by Jonathan Bachmann on 4/14/22.
//

import Foundation

/**
 The ATSC Content Identifier is a structure that is composed of a TSID and a “house number”
 with a period of uniqueness. A “house number” is any number that the holder of the TSID wishes
 as constrained in ATSC Standard A/57B. Numbers are unique for each value of TSID
 */
public struct ATSCContentIdentifier: Codable, Equatable {
    /// This 16 bit unsigned integer field shall contain a value of transport_stream_id per section 6.3.1
    ///  of A/65
    public let tsid: UInt16
    /// 5-bit unsigned integer set to the hour of the day in UTC in which the
    ///  broadcast day ends and the instant after which the `contentId` values may be re-used according to `uniqueFor`
    public let endOfDay: UInt8
    /// 9-bit unsigned integer set to the number of days, rounded up, measured
    ///   relative to the hour indicated by `endOfDay`, during which the `contentId` value is not reassigned
    ///   to different content.
    public let uniqueFor: UInt16
    /// This variable length field shall be set to the value of the identifier according to the
    ///  house number system or systems for the value of TSID.
    public let contentId: String
    // length in bits of the variable length content ID
    private let contentIdLength: Int
}

extension ATSCContentIdentifier: BitCodable {
    init?(from bits: [Bit]) {
        // The number of bits must be greater than the number required
        //  to define the constant length bit fields plus the variable
        //  length bit field, but not to exceed 242 bytes
        guard (33..<(242*8)).contains(bits.count) else { return nil }

        let tsidBits = Array(bits[0..<16])
        //let reservedBits = Array(bits[16..<18])  /// currently unused reserved bit field
        let endDayBits = Array(bits[18..<23])
        let uniqueBits = Array(bits[23..<32])
        contentIdLength = bits.count - 32
        let contentIdBits = Array(bits[32..<bits.count])

        tsid = UInt16(BitConverter.integer(fromBits: tsidBits))
        endOfDay = UInt8(BitConverter.integer(fromBits: endDayBits))
        uniqueFor = UInt16(BitConverter.integer(fromBits: uniqueBits))
        contentId = BitConverter.hexString(fromBits: contentIdBits)
    }

    func encode(into bits: inout [Bit]) throws {
        var newBits = [Bit]()
        newBits.append(contentsOf: BitConverter.bits(from: tsid))
        newBits.append(contentsOf: BitConverter.bits(from: Int(endOfDay), bitArraySize: 5))
        newBits.append(contentsOf: BitConverter.bits(from: Int(uniqueFor), bitArraySize: 9))
        guard let contentIdData = contentId.data(using: .utf8) else { throw SCTE35ParsingError.invalidStringAsUtf8 }
        let contentIdBits = BitConverter.bits(fromData: contentIdData).suffix(contentIdLength)
        newBits.append(contentsOf: contentIdBits)
        
    }
}