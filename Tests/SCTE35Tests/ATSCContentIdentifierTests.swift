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
        guard let contentIdBits = getBits(from: contentIdBitString) else { XCTFail(); return }
        let contentIdVal = BitConverter.hexString(fromBits: contentIdBits)

        let fullBitstring = tsidBitString + reservedBitString + endOfDayBitString + uniqueForBitString + contentIdBitString
        var bits = [Bit]()
        for b in fullBitstring {
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { XCTFail(); return }
            bits.append(bit)
        }

        let atscId = ATSCContentIdentifier(from: bits)
        XCTAssertEqual(atscId?.tsid, tsidVal)
        XCTAssertEqual(atscId?.endOfDay, endOfDayVal)
        XCTAssertEqual(atscId?.uniqueFor, uniqueForVal)
        XCTAssertEqual(atscId?.contentId, contentIdVal)

        if
            let atscJSON = try? JSONEncoder().encode(atscId),
            let atscString = String(bytes: atscJSON, encoding: .utf8)
        {
            print(atscString)
        }
    }

    func testInitFromBitsFailsLongBitFormat() {
        var bits = [Bit]()
        // Create bit string that is longer than 242 bytes
        for b in String(repeating: "0", count: 242*9) {
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { XCTFail(); return }
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
            guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { XCTFail(); return }
            bits.append(bit)
        }

        XCTAssertNil(ATSCContentIdentifier(from: bits))
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
