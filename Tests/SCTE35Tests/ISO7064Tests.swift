//
//  ISO7064Tests.swift
//  
//
//  Created by Jonathan Bachmann on 4/27/22.
//

import XCTest
@testable import SCTE35

class ISO7064Tests: XCTestCase {
    func testCheckCharFromHexChars() {
        let hexString = "B159D8FA01240000"
        XCTAssertEqual(ISO7064.calculateMod3637CheckCharacter(fromHexadecimals: Array(hexString)), "K")
    }

    func testIsanNoVersionFirstCheckDigit() {
        let isanTestString = "B159-D8FA-0124-0000-K"
        let isanHexDecimals = isanTestString.replacingOccurrences(of: "-", with: "").dropLast()
        let expectedCheckChar = Character(String(isanTestString.suffix(1)))
        let isanDecimals: [Int] = isanHexDecimals.compactMap { isanChar in
            return ISO7064.alphanumericCharacterSet.firstIndex(of: isanChar)
        }
        guard isanDecimals.count == isanHexDecimals.count else { XCTFail("Could not create a valid isan decimal array"); return }
        let checkChar = ISO7064.calculateMod3637CheckCharacter(fromDecimals: isanDecimals)
        XCTAssertEqual(expectedCheckChar, checkChar)
    }

    func testIsanWithVersionFirstAndSecondCheckDigit() {
        let isanTestString = "0123-0E00-D07A-0090-O-00A0-070F-G"

        var allIsanHexDecimals = isanTestString.replacingOccurrences(of: "-", with: "")
        let secondCheckDigitIndex = allIsanHexDecimals.index(allIsanHexDecimals.endIndex, offsetBy: -1)
        // Remove and store the 2nd check digit from hex decimals array
        let expectedSecondCheckDigit = allIsanHexDecimals.remove(at: secondCheckDigitIndex)
        // Remove and store the 1st check digit from hex decimals array
        let firstCheckDigitIndex = allIsanHexDecimals.index(allIsanHexDecimals.startIndex, offsetBy: 16)
        let expectedFirstCheckDigit = allIsanHexDecimals.remove(at: firstCheckDigitIndex)

        // Test first check digit calc
        let rootEpisodeHexDecimals = allIsanHexDecimals.prefix(16)
        var isanDecimals: [Int] = rootEpisodeHexDecimals.compactMap { isanChar in
            return ISO7064.alphanumericCharacterSet.firstIndex(of: isanChar)
        }
        guard isanDecimals.count == rootEpisodeHexDecimals.count else { XCTFail("Could not create a valid isan decimal array"); return }
        var checkChar = ISO7064.calculateMod3637CheckCharacter(fromDecimals: isanDecimals)
        XCTAssertEqual(expectedFirstCheckDigit, checkChar)

        // Test second check digit calc
        isanDecimals =  allIsanHexDecimals.compactMap { isanChar in
            return ISO7064.alphanumericCharacterSet.firstIndex(of: isanChar)
        }
        guard isanDecimals.count == allIsanHexDecimals.count else { XCTFail("Could not create a valid isan decimal array"); return }
        checkChar = ISO7064.calculateMod3637CheckCharacter(fromDecimals: isanDecimals)
        XCTAssertEqual(expectedSecondCheckDigit, checkChar)
    }
}
