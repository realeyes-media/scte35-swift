//
//  ATSCContentIdentifierTests.swift
//  
//
//  Created by Jonathan Bachmann on 4/14/22.
//

import XCTest
@testable import SCTE35

class ATSCContentIdentifierTests: XCTestCase {

    func testInitFromBitsCorrectBitFormat() {
        let tsidBitString = "0001000100000010"
        let tsidVal = UInt16(tsidBitString, radix: 2)

        let reservedBitString = "00"

        let endOfDayBitString = "00010"
        let endOfDayVal = UInt8(endOfDayBitString, radix: 2)

        let uniqueForBitString = "001000110"
        let uniqueForVal = UInt16(uniqueForBitString, radix: 2)

        let contentIdBitString = "01100010011100010101"

        let fullBitstring = tsidBitString + reservedBitString + endOfDayBitString + uniqueForBitString + contentIdBitString
        guard let bits = getBits(from: fullBitstring) else { XCTFail("Couldn't create bit array from bit string"); return }
        let atscId = ATSCContentIdentifier(from: bits)
        XCTAssertEqual(atscId?.tsid, tsidVal)
        XCTAssertEqual(atscId?.endOfDay, endOfDayVal)
        XCTAssertEqual(atscId?.uniqueFor, uniqueForVal)

        guard let contentId = atscId?.contentId else {
            XCTFail("contentId is nil")
            return
        }

        let contentIdIntegerRep = withUnsafeBytes(of: contentId) {
            return $0.load(as: Int.self)
        }

        guard let contentIdBits = getBits(from: contentIdBitString) else { XCTFail("Couldn't get bits from string"); return }
        let expectedContentIdInt = BitConverter.integer(fromBits: contentIdBits)
        XCTAssertEqual(contentIdIntegerRep, expectedContentIdInt)
    }

    func testInitFromBitsFailsLongBitFormat() {
        // Create bit string that is longer than 242 bytes
        guard let bits = getBits(from: String(repeating: "0", count: 242*9)) else { XCTFail("Couldn't create bit array from bit string"); return }
        XCTAssertNil(ATSCContentIdentifier(from: bits))
    }

    func testInitFromBitsFailsShortBitFormat() {
        let tsidBitString = "0001000100000010"
        let reservedBitString = "00"
        let endOfDayBitString = "00010"
        let uniqueForBitString = "001000110"
        let contentIdBitString = ""
        let fullBitstring = tsidBitString + reservedBitString + endOfDayBitString + uniqueForBitString + contentIdBitString
        guard let bits = getBits(from: fullBitstring) else { XCTFail("Couldn't create bit array from bit string"); return }
        XCTAssertNil(ATSCContentIdentifier(from: bits))
    }

    func testEncode() {
        let tsid: UInt16 = 40000
        let endOfDay: UInt8 = 125   // this value cannot exceed 2^5 b/c the bit field for this is capped at 5 bits
        let uniqueFor: UInt16 = 500  // this value cannot exceed 2^9 b/c the bit field for this is capped at 9 bits
        let contentId: [Bit] = [
            .zero, .one, .one, .zero, .one, .zero
        ]

        var bits = [Bit]()
        bits.append(contentsOf: BitConverter.bits(from: tsid))
        bits.append(contentsOf: [Bit](repeating: .zero, count: 2))  //reserved section of bits
        bits.append(contentsOf: BitConverter.bits(from: Int(endOfDay), bitArraySize: 5))
        bits.append(contentsOf: BitConverter.bits(from: Int(uniqueFor), bitArraySize: 9))
        bits.append(contentsOf: contentId)

        guard let atsc = ATSCContentIdentifier(from: bits) else {
            XCTFail("Could not create an ATSC instance from bits")
            return
        }

        var encodedBits = [Bit]()
        do {
            let atscBits = try atsc.encode()
            encodedBits.append(contentsOf: atscBits)
        } catch {
            XCTFail("Could not encode ATSC instance into bits")
        }
        XCTAssertEqual(bits, encodedBits)
    }
    
}
