//
//  ConverterTests.swift
//  ConverterTests
//
//  Created by Joe Lucero on 5/29/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import XCTest
@testable import SCTE35

class ConverterTests: XCTestCase {
    let validCue = "/DA9AAAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    // using https://cryptii.com/pipes/base64-to-binary
    let validCuesBinaryString = "11111100001100000011110100000000000000000000000000000000000000000000000000000000000000001000000000000101000001101111111011010001111110000101101011110011000000000010011100000010001001010100001101010101010001010100100101001000000000000000000010111111011111111100111100000000000000001111100011111010011000110000110100010001000011100000010101001100010000010011001100110000001110010000100000001000000000000000000000000000000000000010111001010011100001001000000100110100000000000000000000111100100001101000001000111111"

    let sampleBits: [Bit] = [.zero, .zero, .one, .one, .one, .one, .zero, .zero, .one, .zero, .zero, .zero, .zero, .one, .one, .zero, .one, .zero, .zero, .zero, .zero, .zero, .one, .zero, .zero, .zero, .one, .one, .one, .one, .one, .one]
    let binary = "00111100 10000110 10000010 00111111"
    let hexValueOfBinary = "0x3C86823F"

    let sampleString = "Real Eyes Media: https://www.realeyes.com"
    let sampleStringAsBinary = "01010010 01100101 01100001 01101100 00100000 01000101 01111001 01100101 01110011 00100000 01001101 01100101 01100100 01101001 01100001 00111010 00100000 01101000 01110100 01110100 01110000 01110011 00111010 00101111 00101111 01110111 01110111 01110111 00101110 01110010 01100101 01100001 01101100 01100101 01111001 01100101 01110011 00101110 01100011 01101111 01101101"

    func testBase64ConversionDemonstration() {
        let data = Data(base64Encoded: validCue)!
        let backToString = data.base64EncodedString()

        XCTAssertEqual(validCue, backToString)
    }

    func testBitsFromByteConverter() {
        let expectedRepresentation: [Bit] = [.one, .zero, .one, .zero, .one, .zero, .one, .zero]

        let sampleByteAsUInt8: UInt8 = 128 + 0 + 32 + 0 + 8 + 0 + 2
        let sampleBit = BitConverter.bits(from: sampleByteAsUInt8)

        XCTAssertEqual(expectedRepresentation, sampleBit)
    }

    func testBitsFromUInt16Converter() {
        let expectedRepresentation: [Bit] = [
            .zero, .zero, .zero, .zero, .zero, .zero, .zero, .one,
            .zero, .zero, .zero, .one, .zero, .zero, .one, .one
        ]

        let sampleAsUInt16: UInt16 = 275
        let sampleBits = BitConverter.bits(from: sampleAsUInt16)

        XCTAssertEqual(expectedRepresentation, sampleBits)
    }

    func testBitsFromUInt32Converter() {
        let expectedRepresentation: [Bit] = [
            .zero, .zero, .zero, .zero, .zero, .one, .zero, .one,
            .zero, .one, .zero, .one, .zero, .zero, .zero, .zero,
            .one, .zero, .one, .zero, .zero, .zero, .zero, .zero,
            .zero, .one, .zero, .one, .zero, .zero, .one, .zero
        ]

        let sampleAsUInt32: UInt32 = 89170002
        let sampleBits = BitConverter.bits(from: sampleAsUInt32)

        XCTAssertEqual(expectedRepresentation, sampleBits)
    }

    func testBitsFromIntWithBitArraySize() {
        var expectedRepresentation: [Bit] = [
            .zero, .zero, .zero, .zero, .zero, .one, .one, .one, .zero, .one, .zero
        ]

        var sampleAsInt: Int = 58
        var sampleBits = BitConverter.bits(from: sampleAsInt, bitArraySize: 11)

        XCTAssertEqual(expectedRepresentation, sampleBits)

        // test the edge case where bit array size is a number smaller than the array size needed to
        // represent the provided value
        expectedRepresentation = [
            .zero, .zero, .zero, .zero, .zero
        ]
        sampleAsInt = 256
        sampleBits = BitConverter.bits(from: sampleAsInt, bitArraySize: 5)
        XCTAssertEqual(expectedRepresentation, sampleBits)
    }

    func testBitsFromDataConverter() {
        let data = Data(base64Encoded: validCue)!
        let bits = BitConverter.bits(fromData: data)

        let bitsAsString = bits.reduce("", { (previous, bit) -> String in
            previous + bit.description
        })
        XCTAssertEqual(bitsAsString, validCuesBinaryString)
    }

    func testDataFromBits() {
        let bits: [Bit] = [
            .zero, .zero, .zero, .zero,
            .zero, .zero, .zero, .one,
            .zero, .zero, .one, .zero,
            .zero, .zero, .one, .one,
            .zero, .one, .zero, .zero,
            .zero, .one, .zero, .one,
            .zero, .one, .one, .zero,
            .zero, .one, .one, .one,
            .one, .zero, .zero, .zero,
            .one, .zero, .zero, .one,
            .one, .zero, .one, .zero,
            .one, .zero, .one, .one,
            .one, .one, .zero, .zero,
            .one, .one, .zero, .one,
            .one, .one, .one, .zero,
            .one, .one, .one, .one,
        ]

        let data = BitConverter.data(from: bits)
        XCTAssertEqual(data.count, 8)
        var bitIndex = 0
        for bite in data {
            XCTAssertEqual(UInt8(bite), UInt8(BitConverter.integer(fromBits: Array(bits[bitIndex..<bitIndex+8]))))
            bitIndex += 8
        }
    }

    func testDataFromBitsByteAlignedPadded() {
        let bits: [Bit] = [
            .zero, .zero, .one, .one,
            .zero, .one, .zero, .zero,
            .zero, .one, .zero, .one,
            .zero, .one, .one, .zero,
            .zero, .one, .one, .one,
            .one, .zero, .zero, .zero,
            .one, .zero, .zero, .one,
            .one, .zero, .one, .zero,
            .one, .zero, .one, .one,
            .one, .one, .zero, .zero,
            .one, .one, .zero, .one,
            .one, .one, .one, .zero,
            .one, .one, .one, .one,
        ]

        let data = BitConverter.data(from: bits)
        let integerFromData = withUnsafeBytes(of: data) { $0.load(as: Int.self)  }
        let integerFromBits = BitConverter.integer(fromBits: bits)
        XCTAssertEqual(integerFromData, integerFromBits)
    }

    func testIntegerFromBits() {
        let bits: [Bit] = [.one, .zero, .zero, .one, .zero]
        let expectedValue = 18
        XCTAssertEqual(expectedValue, BitConverter.integer(fromBits: bits))

        let secondBits: [Bit] = [.zero, .zero, .one, .zero, .one]
        let secondExpectedValue = 5
        XCTAssertEqual(secondExpectedValue, BitConverter.integer(fromBits: secondBits))
    }

    func testHexStringFromBits() {
        XCTAssertEqual(sampleBits.count, 32)
        let hexString = BitConverter.hexString(fromBits: sampleBits)
        XCTAssertEqual(hexString, self.hexValueOfBinary)
    }

    func testHexStringWithLeadingZerosFromBits() {
        let bits: [Bit] = [
            .zero, .zero, .zero, .zero,
            .zero, .zero, .zero, .one,
            .zero, .zero, .one, .zero,
            .zero, .zero, .one, .one,
            .zero, .one, .zero, .zero,
            .zero, .one, .zero, .one,
            .zero, .one, .one, .zero,
            .zero, .one, .one, .one,
            .one, .zero, .zero, .zero,
            .one, .zero, .zero, .one,
            .one, .zero, .one, .zero,
            .one, .zero, .one, .one,
            .one, .one, .zero, .zero,
            .one, .one, .zero, .one,
            .one, .one, .one, .zero,
            .one, .one, .one, .one,
        ]
        let expectedString = "0x0123456789ABCDEF"
        let hexString = BitConverter.hexString(fromBits: bits)
        XCTAssertEqual(hexString, expectedString)
    }

    func testBitsFromHex() {
        let expectedBits: [Bit] = [
            .one, .zero, .one, .zero,
            .one, .zero, .one, .one,
            .one, .zero, .zero, .zero,
            .zero, .one, .zero, .zero
        ]

        var hexString = "0xab84"
        var bits = BitConverter.bits(fromHexString: hexString)
        XCTAssertEqual(bits, expectedBits)

        hexString = "0xAB84"
        bits = BitConverter.bits(fromHexString: hexString)
        XCTAssertEqual(bits, expectedBits)
    }

    func testBitsFromHexFailsNotHexChars() {
        let hexString = "12345GHI"
        let bits = BitConverter.bits(fromHexString: hexString)
        XCTAssertNil(bits)
    }

    func testStringFromBits() {
        let sampleBits = sampleStringAsBinary.compactMap { (char) -> Bit? in
            switch char {
            case "0":
                return Bit.zero
            case "1":
                return Bit.one
            default:
                return nil
            }
        }

        let bitsAsString = BitConverter.string(fromBits: sampleBits)!
        XCTAssertEqual(bitsAsString, sampleString)
    }

    func testUMIDStringFromBits() {
        // Derived from the example textual representation in SCTE 35 (2020), table 22
        //  the example contains 8 octets represented in hexidecimal, separated by periods
        let expectedUMIDString = "060A2B34.01010105.01010D20.13000000.D2C9036C.8F195343.AB7014D2.D718BFDA"
        let umIdParts = expectedUMIDString.split(separator: ".")

        var bits = [Bit]()
        for hexString in umIdParts {
            guard let integer = UInt32(hexString, radix: 16) else {
                XCTFail("Could not convert hex string to integer")
                return
            }
            bits.append(contentsOf: BitConverter.bits(from: integer))
        }

        let umid = BitConverter.umidString(fromBits: bits)
        XCTAssertEqual(expectedUMIDString, umid)
    }

    func testBitsFromUMID() {
        // Derived from the example textual representation in SCTE 35 (2020), table 22
        //  the example contains 8 octets represented in hexadecimal, separated by periods
        let umidString = "060A2B34.01010105.01010D20.13000000.D2C9036C.8F195343.AB7014D2.D718BFDA"
        let expectedBits: [Bit] = [.zero, .zero, .zero, .zero, .zero, .one, .one, .zero, .zero, .zero, .zero, .zero, .one,
                                    .zero, .one, .zero, .zero, .zero, .one, .zero, .one, .zero, .one, .one, .zero, .zero,
                                    .one, .one, .zero, .one, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero,
                                    .one, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero,
                                    .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .zero, .one, .zero, .one, .zero,
                                    .zero, .zero, .zero, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .zero, .zero,
                                    .zero, .one, .zero, .zero, .zero, .zero, .one, .one, .zero, .one, .zero, .zero, .one,
                                    .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .one, .zero, .zero, .one, .one,
                                    .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero,
                                    .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .one,
                                    .one, .zero, .one, .zero, .zero, .one, .zero, .one, .one, .zero, .zero, .one,
                                    .zero, .zero, .one, .zero, .zero, .zero, .zero, .zero, .zero, .one, .one, .zero, .one,
                                    .one, .zero, .one, .one, .zero, .zero, .one, .zero, .zero, .zero, .one, .one, .one, .one,
                                    .zero, .zero, .zero, .one, .one, .zero, .zero, .one, .zero, .one, .zero, .one, .zero,
                                    .zero, .one, .one, .zero, .one, .zero, .zero, .zero, .zero, .one, .one, .one, .zero, .one,
                                    .zero, .one, .zero, .one, .one, .zero, .one, .one, .one, .zero, .zero, .zero, .zero, .zero,
                                    .zero, .zero, .one, .zero, .one, .zero, .zero, .one, .one, .zero, .one, .zero, .zero, .one,
                                    .zero, .one, .one, .zero, .one, .zero, .one, .one, .one, .zero, .zero, .zero, .one, .one,
                                    .zero, .zero, .zero, .one, .zero, .one, .one, .one, .one, .one, .one, .one, .one, .zero,
                                    .one, .one, .zero, .one, .zero]
        XCTAssertEqual(expectedBits, BitConverter.bits(fromUMID: umidString))
    }

    func testIsanStringFromBitsNoVersion() {
        let isanTestString = "B159-D8FA-0124-0000-K"
        guard let bits = BitConverter.bits(fromIsan: isanTestString) else { XCTFail("Could not create bit array from ISAN"); return }
        XCTAssertEqual(isanTestString, BitConverter.isanString(fromBits: bits))
    }

    func testIsanStringFromBitsWithVersion() {
        let isanTestString = "0123-0E00-D07A-0090-O-00A0-070F-G"
        guard let bits = BitConverter.bits(fromIsan: isanTestString) else { XCTFail("Could not create bit array from ISAN"); return }
        XCTAssertEqual(isanTestString, BitConverter.isanString(fromBits: bits))
    }

    func testEidrStringFromBits() {
        // Derived from the example textual representation in SCTE 35 (2020), table 22
        let expectedEidrString = "10.5240/0E4F-892E-442F-6BD4-15B0-1"
        let bits: [Bit] = [.zero, .zero, .zero, .one, .zero, .one, .zero, .zero, .zero, .one, .one, .one, .one, .zero, .zero,
                            .zero, .zero, .zero, .zero, .zero, .one, .one, .one, .zero, .zero, .one, .zero, .zero, .one, .one,
                            .one, .one, .one, .zero, .zero, .zero, .one, .zero, .zero, .one, .zero, .zero, .one, .zero, .one,
                            .one, .one, .zero, .zero, .one, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .one, .zero,
                            .one, .one, .one, .one, .zero, .one, .one, .zero, .one, .zero, .one, .one, .one, .one, .zero, .one,
                            .zero, .one, .zero, .zero, .zero, .zero, .zero, .one, .zero, .one, .zero, .one, .one, .zero, .one,
                            .one, .zero, .zero, .zero, .zero]
        guard let eidrString = BitConverter.eidrString(fromBits: bits) else { XCTFail("Could not create EIDR string from bits"); return }
        XCTAssertEqual(eidrString, expectedEidrString)
    }

    func testBitsFromEidrString() {
        // Derived from the example textual representation in SCTE 35 (2020), table 22
        let eidrString = "10.5240/0E4F-892E-442F-6BD4-15B0-1"
        let expectedBits: [Bit] = [.zero, .zero, .zero, .one, .zero, .one, .zero, .zero, .zero, .one, .one, .one, .one, .zero, .zero,
                            .zero, .zero, .zero, .zero, .zero, .one, .one, .one, .zero, .zero, .one, .zero, .zero, .one, .one,
                            .one, .one, .one, .zero, .zero, .zero, .one, .zero, .zero, .one, .zero, .zero, .one, .zero, .one,
                            .one, .one, .zero, .zero, .one, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .one, .zero,
                            .one, .one, .one, .one, .zero, .one, .one, .zero, .one, .zero, .one, .one, .one, .one, .zero, .one,
                            .zero, .one, .zero, .zero, .zero, .zero, .zero, .one, .zero, .one, .zero, .one, .one, .zero, .one,
                            .one, .zero, .zero, .zero, .zero]
        guard let bits = BitConverter.bits(fromEidr: eidrString) else { XCTFail("Could not create bit array from EIDR"); return }
        XCTAssertEqual(bits, expectedBits)
    }

    func testAdIdStringFromBits() {
        let testCases = [
            ("ABCD12345678", true),
            ("ABCD1234ABCD", true),
            ("12ABCDEFGHIJ", false),
            ("A34", false),
            ("ABCD1234ABCD1234", false),
            ("ćë123456789ū", false),
            ("!B1234567890", false),
            ("AB123456789!", false),
        ]

        for testCase in testCases {
            guard let data = testCase.0.data(using: .utf8) else {
                XCTFail("Couldn't convert \(testCase.0) into data")
                continue
            }

            let string = BitConverter.adIdString(from: BitConverter.bits(fromData: data))
            if testCase.1 == true {
                XCTAssertEqual(testCase.0, string)
            } else {
                XCTAssertNil(string)
            }
        }
    }

    func testTidStringFromBits() {
        let testCases = [
            ("AB1234567890", true),
            ("12ABCDEFGHIJ", false),
            ("A34", false),
            ("AB12345678901234", false),
            ("ćë123456789ū", false),
            ("!B1234567890", false),
            ("AB123456789!", false),
        ]

        for testCase in testCases {
            guard let data = testCase.0.data(using: .utf8) else {
                XCTFail("Couldn't convert \(testCase.0) into data")
                continue
            }

            let string = BitConverter.tidString(from: BitConverter.bits(fromData: data))
            if testCase.1 == true {
                XCTAssertEqual(testCase.0, string)
            } else {
                XCTAssertNil(string)
            }
        }
    }

    func testADIStringFromBits() {
        let testCases = [
            ("PO : provider.com/MOVE1234567890123456", true),
            ("SIGNAL:provider.com/MOVE1234567890123456", true),
            ("SIGNAL:provider.com?MOVE1234567890123456", false),
            ("bad", false),
            ("", false)
        ]

        for testCase in testCases {
            guard let data = testCase.0.data(using: .utf8) else {
                XCTFail("Couldn't convert \(testCase.0) into data")
                continue
            }

            let string = BitConverter.adiString(from: BitConverter.bits(fromData: data))
            if testCase.1 == true {
                guard let theString = string else { XCTFail("Expected a valid adi String"); return}
                XCTAssertTrue(testCase.0.contains(theString))
            } else {
                XCTAssertNil(string)
            }
        }
    }


}
