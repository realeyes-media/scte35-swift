//
//  SegmentationUPIDTests.swift
//  
//
//  Created by Jonathan Bachmann on 4/22/22.
//

import XCTest
@testable import SCTE35

class SegmentationUPIDTests: XCTestCase {
    func testISCI() {
        let isci = "ABCD1234"
        guard let isciData = isci.data(using: .utf8) else {
            XCTFail("Could not create data bytes from string")
            return
        }
        let upid = SegmentationUPID(type: 0x02, length: isciData.count, relevantBits: BitConverter.bits(fromData: isciData))
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.ISCI(isci))
        XCTAssertEqual(upid?.type, 0x02)
    }

    func testAdID() {
        let adId = "ABCD0001000H"
        guard let adIdData = adId.data(using: .utf8) else {
            XCTFail("Could not create data bytes from string")
            return
        }
        let upid = SegmentationUPID(type: 0x03, length: adIdData.count, relevantBits: BitConverter.bits(fromData: adIdData))
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.AdID(adId))
        XCTAssertEqual(upid?.type, 0x03)
    }

    func testUMID() {
        let umId = "060A2B34.01010105.01010D20.13000000.D2C9036C.8F195343.AB7014D2.D718BFDA"
        guard let umIdBits = BitConverter.bits(fromUMID: umId) else {
            XCTFail("Could not get bits from UMID string")
            return
        }
        let upid = SegmentationUPID(type: 0x04, length: 32, relevantBits: umIdBits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.UMID(umId))
        XCTAssertEqual(upid?.type, 0x04)
    }

    func testISAN() {
        let isanTestString = "B159-D8FA-0124-0000-K"
        guard let bits = BitConverter.bits(fromIsan: isanTestString) else { XCTFail("Could not create bit array from ISAN"); return }
        let isan = SegmentationUPID(type: 0x05, length: 8, relevantBits: bits)
        XCTAssertEqual(isan?.info, SegmentationUPIDInformation.ISAN(isanTestString))
        XCTAssertEqual(isan?.type, 0x05)
    }

    func testVISAN() {
        let isanTestString = "0123-0E00-D07A-0090-O-00A0-070F-G"
        guard let bits = BitConverter.bits(fromIsan: isanTestString) else { XCTFail("Could not create bit array from ISAN"); return }
        let isan = SegmentationUPID(type: 0x06, length: 12, relevantBits: bits)
        XCTAssertEqual(isan?.info, SegmentationUPIDInformation.VISAN(isanTestString))
        XCTAssertEqual(isan?.type, 0x06)
    }

    func testTID() {

    }

    func testTI() {

    }

    func testADI() {

    }

    func testEIDR() {

    }

    func testATSC() {

    }

    func testMPU() {

    }

    func testMID() {

    }

    func testADS() {

    }

    func testURI() {

    }

    func testUUID() {

    }
}
