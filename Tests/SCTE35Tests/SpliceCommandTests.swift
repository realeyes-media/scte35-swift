//
//  SpliceCommandTests.swift
//  SCTE35ConverterTests
//
//  Created by Joe Lucero on 5/31/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import XCTest
@testable import SCTE35

class SpliceCommandTests: XCTestCase {

    let spliceInsertCue =  "/DAvAAAAAAAAAP///wViAAWKf+//CXVCAv4AUmXAAzUAAAAKAAhDVUVJADgyMWLvc/g="
    let secondSpliceInsertCue = "/DAvAAAAAAAA///wFAVIAACPf+/+c2nALv4AUsz1AAAAAAAKAAhDVUVJAAABNWLbowo="
    let invalidInsertCue = "/DA1AAAAAAAAAP/wEBRiAAWKf+9/f3VCAv4AUmXAABQACAAKAAhDVUVJAAgACENVRUkAOLssdEQ="

    let timeSignalCue = "/DBLAAAAAAAA///wBQb+AAAAAAA1AjNDVUVJYgAFin//AABSZcAJH1NJR05BTDpEUjIxWjA3WlQ4YThhc25pdVVoZWlBPT00AADz3GdX"
    let secondTimeSignalCue = "/DBhAAAAAAAA///wBQb+qM1E7QBLAhdDVUVJSAAArX+fCAgAAAAALLLXnTUCAAIXQ1VFSUgAACZ/nwgIAAAAACyy150RAAACF0NVRUlIAAAnf58ICAAAAAAsstezEAAAihiGnw=="
    let thirdTimeSignalCue = "/DB5AAAAAAAAAP/wBQb/DkfmpABjAhdDVUVJhPHPYH+/CAgAAAAABy4QajEBGAIcQ1VFSYTx71B//wAAK3NwCAgAAAAABy1cxzACGAIqQ1VFSYTx751/vwwbUlRMTjFIAQAAAAAxMzU2MTY2MjQ1NTUxQjEAAQAALL95dg=="
    let fourthTimeSignalCue = "/DA9AAAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="

    let converter = SCTE35Converter()

    func testSpliceInsert() {
        let spliceInfoSection = try! converter.parseFrom(base64String: spliceInsertCue)
        switch spliceInfoSection.spliceCommand {
        case .insert(insertEvent: let event):
            XCTAssertEqual(event.id, 1644168586)
            XCTAssertEqual(event.info!.spliceTime!.ptsTime, 4453646850)
        default:
            XCTAssert(false)
        }
    }

    func testSecondSpliceInsertCue() {
        let secondSpliceInsert = try! converter.parseFrom(base64String: secondSpliceInsertCue)
        switch secondSpliceInsert.spliceCommand {
        case .insert(insertEvent: let event):
            XCTAssertEqual(event.id, 0x4800008f)
            XCTAssertEqual(event.info!.isOutOfNetwork, true)
            XCTAssertEqual(event.info!.shouldSpliceImmediately, false)
            XCTAssertEqual(event.info!.breakDuration?.duration,  0x00052ccf5)
        default:
            XCTAssert(false)
        }
    }

    func testInvalidInsertCue() {
        do {
            let _ = try converter.parseFrom(base64String: invalidInsertCue)
            XCTFail("Unexpectedly succeeded in parsing invalid cue")
        } catch SCTE35ParsingError.unableToParseDescriptor(let theType) {
            XCTAssertEqual(theType, DescriptorType.avail)
        } catch {
            XCTFail("Unexpected error thrown from parseFrom: \(error)")
        }
    }

    func testTimeSignalCue() {
        let timeSignal = try! converter.parseFrom(base64String: timeSignalCue)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 0)
        default:
            XCTAssert(false)
        }
    }

    func testSecondTimeSignalCue() {
        let secondTimeSignal = try! converter.parseFrom(base64String: secondTimeSignalCue)
        switch secondTimeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 2832024813)
        default:
            XCTAssert(false)
        }
    }

    func testThirdTimeSignalCue() {
        let thirdTimeSignal = try! converter.parseFrom(base64String: thirdTimeSignalCue)
        switch thirdTimeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 4534560420)
        default:
            XCTAssert(false)
        }
    }

    func testFourthTimeSignalCue() {
        let fourthTimeSignal = try! converter.parseFrom(base64String: fourthTimeSignalCue)
        switch fourthTimeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 3522714355)
        default:
            XCTAssert(false)
        }
    }
}
