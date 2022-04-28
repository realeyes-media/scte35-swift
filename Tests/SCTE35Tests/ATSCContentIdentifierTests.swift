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
        guard let contentIdBits = getBits(from: contentIdBitString) else { XCTFail("Couldn't get bits from string"); return }
        let contentIdVal = BitConverter.hexString(fromBits: contentIdBits)

        let fullBitstring = tsidBitString + reservedBitString + endOfDayBitString + uniqueForBitString + contentIdBitString
        var bits = [Bit]()
        for b in fullBitstring {
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { XCTFail("Couldn't create Bit instance from raw value"); return }
            bits.append(bit)
        }

        let atscId = ATSCContentIdentifier(from: bits)
        XCTAssertEqual(atscId?.tsid, tsidVal)
        XCTAssertEqual(atscId?.endOfDay, endOfDayVal)
        XCTAssertEqual(atscId?.uniqueFor, uniqueForVal)
        XCTAssertEqual(atscId?.contentId, contentIdVal)
    }

    func testInitFromBitsFailsLongBitFormat() {
        var bits = [Bit]()
        // Create bit string that is longer than 242 bytes
        for b in String(repeating: "0", count: 242*9) {
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { XCTFail("Couldn't create Bit instance from raw value"); return }
            bits.append(bit)
        }

        XCTAssertNil(ATSCContentIdentifier(from: bits))
    }

    func testInitFromBitsFailsShortBitFormat() {
        let tsidBitString = "0001000100000010"
        let reservedBitString = "00"
        let endOfDayBitString = "00010"
        let uniqueForBitString = "001000110"
        let contentIdBitString = ""

        let fullBitstring = tsidBitString + reservedBitString + endOfDayBitString + uniqueForBitString + contentIdBitString
        var bits = [Bit]()
        for b in fullBitstring {
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { XCTFail("Couldn't create Bit instance from raw value"); return }
            bits.append(bit)
        }

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

    private func getBits(from string: String) -> [Bit]? {
        var bits = [Bit]()
        for b in string {
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { return nil }
            bits.append(bit)
        }
        return bits
    }

}
