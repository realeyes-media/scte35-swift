//
//  ThrownErrorTests.swift
//  SCTE35ConverterTests
//
//  Created by Joe Lucero on 5/29/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import XCTest
@testable import SCTE35_SwiftLibrary

class ThrownErrorTests: XCTestCase {

    let converter = SCTE35Converter()
    
    let invalidBase64String = "a"
    let base64StringTooShort = "aaaaaaaa"
    let invalidTableID = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    let sectionLengthTooLarge = "/D//9AAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4"
    let sectionLengthTooShort = "/DA9BAAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCP5SgqKo="
    let invalidProtocolVersion = "/DA9BAAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="

    func testInvalidBase64String() {
        do {
            let _ = try converter.parseFrom(base64String: invalidBase64String)
            XCTAssert(false)
        } catch SCTE35ParsingError.invalidBase64String {
            XCTAssert(true)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }

    func testBase64StringTooShort() {
        do {
            let _ = try converter.parseFrom(base64String: base64StringTooShort)
            XCTAssert(false)
        } catch SCTE35ParsingError.base64StringTooShort {
            XCTAssert(true)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }

    func testInvalidTableID() {
        do {
            let _ = try converter.parseFrom(base64String: invalidTableID)
            XCTAssert(false)
        } catch SCTE35ParsingError.invalidTableID {
            XCTAssert(true)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }

    func testSectionLengthTooLarge() {
        do {
            let _ = try converter.parseFrom(base64String: sectionLengthTooLarge)
            XCTAssert(false)
        } catch SCTE35ParsingError.sectionLengthIncorrect {
            XCTAssert(true)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }

    func testSectionLengthTooShort() {
        do {
            let _ = try converter.parseFrom(base64String: sectionLengthTooShort)
            XCTAssert(false)
        } catch SCTE35ParsingError.sectionLengthIncorrect {
            XCTAssert(true)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }

    func testInvalidProtocolVersion() {
        do {
            let _ = try converter.parseFrom(base64String: invalidProtocolVersion)
            XCTAssert(false)
        } catch SCTE35ParsingError.invalidProtocolVersion {
            XCTAssert(true)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
}
