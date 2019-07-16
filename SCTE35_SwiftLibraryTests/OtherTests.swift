//
//  OtherTests.swift
//  SCTE35-SwiftLibrary
//
//  Created by Joe Lucero on 6/28/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import XCTest
@testable import SCTE35

class OtherTests: XCTestCase {

    let converter = SCTE35Converter()

    let encryptedCue = "/DA9AIAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    let desECBEncryption = "/DA9AAIAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    let desCBCEncryption = "/DA9AAQAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    let userEncryption = "/DA9AHwAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    let ptsAdjustmentOf10 = "/DA9AAAAAAAKAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    let cwIndexOf129Cue = "/DA9AAAAAAABgQCABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    let maxTierCue = "/DA9AAAAAAAAAP/wBQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="

    func testEncryptedPacket() {
        let isEncrypted = try! converter.parseFrom(base64String: encryptedCue)
        XCTAssertTrue(isEncrypted.hasEncryptedPacket)
    }

    func testEncryptionAlgorithm() {
        let desECB = try! converter.parseFrom(base64String: desECBEncryption)
        XCTAssertTrue(desECB.encryptionAlgorithm == .desECBMode)

        let desCBC = try! converter.parseFrom(base64String: desCBCEncryption)
        XCTAssertTrue(desCBC.encryptionAlgorithm == .desCBCMode)

        let user = try! converter.parseFrom(base64String: userEncryption)
        XCTAssertTrue(user.encryptionAlgorithm == .userPrivate)
    }

    func testPtsAdjustment() {
        let pts = try! converter.parseFrom(base64String: ptsAdjustmentOf10)
        XCTAssertEqual(pts.ptsAdjustment, 10)
    }

    func testCWIndex() {
        let cwIndexOf129 = try! converter.parseFrom(base64String: cwIndexOf129Cue)
        XCTAssertEqual(cwIndexOf129.cwIndex, 129)
    }

    func testMaxTier() {
        let maxTier = try! converter.parseFrom(base64String: maxTierCue)
        XCTAssertEqual(maxTier.tier.hexRepresentation, "0xFFF")
    }

}
