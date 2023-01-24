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
public struct ATSCContentIdentifier: Equatable, BitCodable {
    /// This 16 bit unsigned integer field shall contain a value of transport_stream_id per section 6.3.1 of A/65
    public let tsid: UInt16

    /**
     5-bit unsigned integer set to the hour of the day in UTC in which the
     broadcast day ends and the instant after which the `contentId` values may be re-used according to `uniqueFor`
     */
    public let endOfDay: UInt8

    /**
     9-bit unsigned integer set to the number of days, rounded up, measured
     relative to the hour indicated by `endOfDay`, during which the `contentId` value is not reassigned
     to different content.
     */
    public let uniqueFor: UInt16

    /**
     This variable length field shall be set to the value of the identifier according to the
     house number system or systems for the value of TSID.  Must be UTF8 encoded.
     */
    private let _contentId: [Bit]

    /// Content ID value represented as a `Data` instance
    public var contentId: Data {
        let integerRep = BitConverter.integer(fromBits: _contentId)
        var data = Data()
        withUnsafeBytes(of: integerRep) {
            data.append(contentsOf: $0)
        }
        return data
    }

    init?(from bits: [Bit]) {
        /*
         The number of bits must be greater than the number required
         to define the constant length bit fields plus the variable
         length bit field for content ID, but not to exceed 242 bytes
         */
        guard (33..<(242*8)).contains(bits.count) else { return nil }

        let tsidBits = Array(bits[0..<16])
        //let reservedBits = Array(bits[16..<18])  /// currently unused reserved bit field
        let endDayBits = Array(bits[18..<23])
        let uniqueBits = Array(bits[23..<32])
        let contentIdBits = Array(bits[32..<bits.count])

        tsid = UInt16(BitConverter.integer(fromBits: tsidBits))
        endOfDay = UInt8(BitConverter.integer(fromBits: endDayBits))
        uniqueFor = UInt16(BitConverter.integer(fromBits: uniqueBits))
        _contentId = contentIdBits
    }

    func encode() throws -> [Bit] {
        var bits = [Bit]()
        bits.append(contentsOf: BitConverter.bits(from: tsid))
        bits.append(contentsOf: [Bit](repeating: .zero, count: 2)) // reserved bits
        bits.append(contentsOf: BitConverter.bits(from: Int(endOfDay), bitArraySize: 5))
        bits.append(contentsOf: BitConverter.bits(from: Int(uniqueFor), bitArraySize: 9))
        bits.append(contentsOf: _contentId)
        return bits
    }
}
