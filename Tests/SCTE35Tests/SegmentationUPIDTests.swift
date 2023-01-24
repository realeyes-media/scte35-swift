//
//  SegmentationUPIDTests.swift
//  
//
//  Created by Jonathan Bachmann on 4/22/22.
//

import XCTest
@testable import SCTE35

class SegmentationUPIDTests: XCTestCase {
    func testUserDefined() {
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
        let upid = SegmentationUPID(type: 0x01, length: bits.count/8, relevantBits: bits)
        let data = BitConverter.data(from: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.userDefined(data))
        XCTAssertEqual(upid?.type, 0x01)
    }

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
        guard let bits = BitConverter.bits(fromUMID: umId) else {
            XCTFail("Could not get bits from UMID string")
            return
        }
        let upid = SegmentationUPID(type: 0x04, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.UMID(umId))
        XCTAssertEqual(upid?.type, 0x04)
    }

    func testISAN() {
        let isan = "B159-D8FA-0124-0000-K"
        guard let bits = BitConverter.bits(fromIsan: isan) else {
            XCTFail("Could not create bit array from ISAN")
            return
        }
        let upid = SegmentationUPID(type: 0x05, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.ISAN(isan))
        XCTAssertEqual(upid?.type, 0x05)
    }

    func testVISAN() {
        let isan = "0123-0E00-D07A-0090-O-00A0-070F-G"
        guard let bits = BitConverter.bits(fromIsan: isan) else {
            XCTFail("Could not create bit array from ISAN")
            return
        }
        let upid = SegmentationUPID(type: 0x06, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.VISAN(isan))
        XCTAssertEqual(upid?.type, 0x06)
    }

    func testTID() {
        let tid = "AB1234567890"
        guard let tidData = tid.data(using: .utf8) else {
            XCTFail("Could not create data bytes from string")
            return
        }
        let upid = SegmentationUPID(type: 0x07, length: tidData.count, relevantBits: BitConverter.bits(fromData: tidData))
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.TID(tid))
        XCTAssertEqual(upid?.type, 0x07)
    }

    func testTI() {
        let ti = "0x0A42235B81BC70FC"
        guard let bits = BitConverter.bits(fromHexString: ti) else {
            XCTFail("Could not create bit array from TI")
            return
        }
        let upid = SegmentationUPID(type: 0x08, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.TI(ti))
        XCTAssertEqual(upid?.type, 0x08)
    }

    func testADI() {
        let adiId = "provider.com/MOVE1234567890123456"
        let adi = "SIGNAL:\(adiId)"
        guard let data = adi.data(using: .utf8) else {
            XCTFail("Could not create bits from ADI string")
            return
        }
        let bits = BitConverter.bits(fromData: data)
        let upid = SegmentationUPID(type: 0x09, length: data.count, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.ADI(adiId))
        XCTAssertEqual(upid?.type, 0x09)
    }

    func testEIDR() {
        let eidr = "10.5240/0E4F-892E-442F-6BD4-15B0-1"
        let eidrSuffixHexChars = "0E4F892E442F6BD415B0"
        guard
            let eidrSubPrefix = UInt16("5240", radix: 10),
            let suffixBits = BitConverter.bits(fromHexString: eidrSuffixHexChars) else {
            XCTFail("Could not create bit array from EIDR string info")
            return
        }

        let bits = BitConverter.bits(from: eidrSubPrefix) + suffixBits
        let upid = SegmentationUPID(type: 0x0A, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.EIDR(eidr))
        XCTAssertEqual(upid?.type, 0x0A)
    }

    func testATSC() {
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

        guard let expectedAtsc = ATSCContentIdentifier(from: bits) else {
            XCTFail("Could not create an ATSC instance from bits")
            return
        }

        let upid = SegmentationUPID(type: 0x0B, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.ATSC(expectedAtsc))
        XCTAssertEqual(upid?.type, 0x0B)
    }

    func testMID() {
        let umidType: UInt8 = 0x4
        let umId = "060A2B34.01010105.01010D20.13000000.D2C9036C.8F195343.AB7014D2.D718BFDA"
        guard let umidBits = BitConverter.bits(fromUMID: umId) else {
            XCTFail("Could not get bits from UMID string")
            return
        }

        let isanType: UInt8 = 0x6
        let isan = "0123-0E00-D07A-0090-O-00A0-070F-G"
        guard let isanBits = BitConverter.bits(fromIsan: isan) else {
            XCTFail("Could not create bit array from ISAN")
            return
        }

        var bits = [Bit]()
        bits.append(contentsOf: BitConverter.bits(from: umidType))
        bits.append(contentsOf: BitConverter.bits(from: umidBits.count/8, bitArraySize: 8))
        bits.append(contentsOf: umidBits)
        bits.append(contentsOf: BitConverter.bits(from: isanType))
        bits.append(contentsOf: BitConverter.bits(from: isanBits.count/8, bitArraySize: 8))
        bits.append(contentsOf: isanBits)

        let upid = SegmentationUPID(type: 0x0D, length: bits.count/8, relevantBits: bits)
        XCTAssertNotNil(upid?.info)
        XCTAssertEqual(upid?.type, 0x0D)

        switch upid?.info {
        case .MID(let multiUpids):
            XCTAssertEqual(multiUpids.count, 2)
            XCTAssertEqual(multiUpids.first?.info, SegmentationUPIDInformation.UMID(umId))
            XCTAssertEqual(multiUpids.last?.info, SegmentationUPIDInformation.VISAN(isan))
        default:
            XCTFail("upid info type is not the a multi upid")
        }
    }

    func testURI() {
        let uri = "urn:uuid:f81d4fae7dec-11d0-a765-00a0c91e6bf6"
        guard let uriData = uri.data(using: .utf8) else {
            XCTFail("Could not create data bytes from string")
            return
        }
        let upid = SegmentationUPID(type: 0x0F, length: uriData.count, relevantBits: BitConverter.bits(fromData: uriData))
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.URI(uri))
        XCTAssertEqual(upid?.type, 0x0F)
    }

    func testUUID() {
        let uuid = "0xCB0350A948774CA7BB638730B37A98CF"
        guard let bits = BitConverter.bits(fromHexString: uuid) else {
            XCTFail("Could not create bit array from UUID")
            return
        }
        let upid = SegmentationUPID(type: 0x10, length: bits.count/8, relevantBits: bits)
        XCTAssertEqual(upid?.info, SegmentationUPIDInformation.UUID(uuid))
        XCTAssertEqual(upid?.type, 0x10)
    }
}
