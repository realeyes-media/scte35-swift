//
//  ValidCueTests.swift
//  SCTE35ConverterTests
//
//  Created by Joe Lucero on 6/5/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import XCTest
@testable import SCTE35

class ValidCueTests: XCTestCase {

    let converter = SCTE35Converter()

    let validTimeSegAdIdCue = "/DA4AAAAAAAA///wBQb+AAAAAAAiAiBDVUVJAAAAA3//AAApPWwDDEFCQ0QwMTIzNDU2SBAAAGgCL9A="
    func testValidTimeSegAdIdCue() {

        let timeSignal = try! converter.parseFrom(base64String: validTimeSegAdIdCue)
        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 56)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 255)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 0)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 34)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 32)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 3)
            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)
            XCTAssertNil(additionalInfo.restrictions)
            XCTAssertNil(additionalInfo.pidComponents)

            XCTAssertEqual(additionalInfo.segmentationDuration, 2702700)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 3)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "Ad-ID")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "Defined by the Advertising Digital Identification, LLC group. 12 characters; 4 alpha characters (company identification prefix) followed by 8 alphanumeric characters. (See [Ad-ID])")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .AdID(let string):
                XCTAssertEqual(string, "ABCD0123456H")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0x68022FD0")
        XCTAssertNil(timeSignal.ecrc32)
    }

    let validTimeSegUmidCue = "/DBHAAAAAAAA///wBQb+AAAAAAAxAi9DVUVJAAAAA3+/BCAGCis0AQEBBQEBDSATAAAA0skDbI8ZU0OrcBTS1xi/2hEAAPUV9+0="
    func testValidTimeSegUmidCue() {
        let timeSignal = try! converter.parseFrom(base64String: validTimeSegUmidCue)
        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 71)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 255)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 0)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 49)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 47)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 3)

            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, false)
            XCTAssertNil(additionalInfo.restrictions)
            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertEqual(additionalInfo.segmentationDuration, nil)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 4)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "UMID")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "See [SMPTE 330]")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .UMID(let string):
                XCTAssertEqual(string, "060A2B34.01010105.01010D20.13000000.D2C9036C.8F195343.AB7014D2.D718BFDA")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programEnd)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0xF515F7ED")
        XCTAssertNil(timeSignal.ecrc32)
    }

    let validTimeSegIsanCue = "/DA4AAAAAAAA///wBQb+AAAAAAAiAiBDVUVJAAAAA3//AAApPWwGDBU8c2Wzb4RMhzSUIBAAAHVCIBw="
    func testValidTimeSegIsanCue() {

        let timeSignal = try! converter.parseFrom(base64String: validTimeSegIsanCue)
        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 56)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 255)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 0)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 34)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 32)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 3)

            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)
            XCTAssertNil(additionalInfo.restrictions)
            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertEqual(additionalInfo.segmentationDuration, 2702700)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 6)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "V-ISAN")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "Formerly known as V-ISAN. ISO 15706-2 binary encoding (“versioned” ISAN). See [ISO 15706-2].")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            // TODO: - these question marks are placeholders until we can write an algorithm that follows ISO 7064 mod 37, 36 standards
            // Examples online are few and wildly inconsistent
            switch upidInfo {
            case .VISAN(let string):
                XCTAssertEqual(string, "153C-7365-B36F-844C-7-8734-9420-T")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0x7542201C")
        XCTAssertNil(timeSignal.ecrc32)
    }


    let validTimeSegTidCue = "/DA4AAAAAAAA///wBQb+AAAAAAAiAiBDVUVJAAAAA3//AAApPWwHDE1WMDAwNDE0NjQwMBAAAIH4Mwc="
    func testValidTimeSegTidCue() {
        let timeSignal = try! converter.parseFrom(base64String: validTimeSegTidCue)

        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 56)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 255)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 0)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 34)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 32)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 3)

            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)
            XCTAssertNil(additionalInfo.restrictions)
            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertEqual(additionalInfo.segmentationDuration, 2702700)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 7)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "TID")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "Tribune Media Systems Program identifier. 12 characters; 2 alpha characters followed by 10 numbers.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .TID(let string):
                XCTAssertEqual(string, "MV0004146400")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0x81F83307")
        XCTAssertNil(timeSignal.ecrc32)
    }

    let validTimeSegAiringCue = "0xFC3048000000000000FFFFF00506FE932E380B00320217435545494800000A7F9F0808000000002CA0A1E3180000021743554549480000097F9F0808000000002CA0A18A110000B4217EB0"
    func testValidTimeSegAiringCue() {
        let timeSegAiring = try! converter.parseFrom(hexString: validTimeSegAiringCue)

        XCTAssertEqual(timeSegAiring.tableID, 252)
        XCTAssertEqual(timeSegAiring.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSegAiring.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSegAiring.sectionLength, 72)
        XCTAssertEqual(timeSegAiring.protocolVersion, 0)
        XCTAssertEqual(timeSegAiring.hasEncryptedPacket, false)
        XCTAssertEqual(timeSegAiring.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSegAiring.ptsAdjustment, 0)
        XCTAssertEqual(timeSegAiring.cwIndex, 255)
        XCTAssertEqual(timeSegAiring.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSegAiring.spliceCommandLength, 5)
        XCTAssertEqual(timeSegAiring.spliceCommandType, 6)
        switch timeSegAiring.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 2469279755)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSegAiring.descriptorLoopLength, 50)
        XCTAssertEqual(timeSegAiring.spliceDescriptors.count, 2)
        switch timeSegAiring.spliceDescriptors[0] {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 23)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 1207959562)

            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, false)

            guard let restrictions = additionalInfo.restrictions else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(restrictions.isWebDeliveryAllowed, true)
            XCTAssertEqual(restrictions.isNotRegionallyBlackedOut, true)
            XCTAssertEqual(restrictions.isArchiveAllowed, true)
            XCTAssertEqual(restrictions.deviceRestrictions, DeviceRestrictions.noRestrictions)

            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertNil(additionalInfo.segmentationDuration)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 8)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "TI")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "AiringID (Formerly Turner ID), used to indicate a specific airing of a program that is unique within a network.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .TI(let string):
                XCTAssertEqual(string, "0x000000002CA0A1E3")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programBlackoutOverride)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        switch timeSegAiring.spliceDescriptors[1] {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 23)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 1207959561)

            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, false)

            guard let restrictions = additionalInfo.restrictions else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(restrictions.isWebDeliveryAllowed, true)
            XCTAssertEqual(restrictions.isNotRegionallyBlackedOut, true)
            XCTAssertEqual(restrictions.isArchiveAllowed, true)
            XCTAssertEqual(restrictions.deviceRestrictions, DeviceRestrictions.noRestrictions)

            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertNil(additionalInfo.segmentationDuration)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 8)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "TI")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "AiringID (Formerly Turner ID), used to indicate a specific airing of a program that is unique within a network.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .TI(let string):
                XCTAssertEqual(string, "0x000000002CA0A18A")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programEnd)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSegAiring.crc32, "0xB4217EB0")
        XCTAssertNil(timeSegAiring.ecrc32)

    }

    let validTimeSegEidrCue = "/DA4AAAAAAAA///wBQb+AAAAAAAiAiBDVUVJAAAAA3//AAApPWwKDBR4+FrhALBoW4+xyBAAAGij1lQ="
    func testValidTimeSegEidrCue() {
        let timeSignal = try! converter.parseFrom(base64String: validTimeSegEidrCue)

        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 56)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 255)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 0)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 34)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 32)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 3)

            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)
            XCTAssertNil(additionalInfo.restrictions)
            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertEqual(additionalInfo.segmentationDuration, 2702700)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 10)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "EIDR")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "An EIDR (see [EIDR]) represented in Compact Binary encoding as defined in Section 2.1.1 in EIDR ID Format (see [EIDR ID FORMAT])")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            // TODO: - these question marks are placeholders until we can write an algorithm that follows ISO 7064 mod 37, 36 standards
            // Examples online are few and wildly inconsistent
            switch upidInfo {
            case .EIDR(let string):
                XCTAssertEqual(string, "10.5240/F85A-E100-B068-5B8F-B1C8-T")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .programStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0x68A3D654")
        XCTAssertNil(timeSignal.ecrc32)
    }


    let validSpliceInsertOutCue = "/DAlAAAAAAAAAP/wFAUAAAPvf+//adb6P/4AUmXAAAAAAAAAoeikig=="
    func testValidSpliceInsertOutCue() {
        let timeSignal = try! converter.parseFrom(base64String: validSpliceInsertOutCue)

        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 37)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 0)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 20)
        XCTAssertEqual(timeSignal.spliceCommandType, 5)
        switch timeSignal.spliceCommand {
        case .insert(insertEvent: let insertEvent):
            XCTAssertEqual(insertEvent.id, 1007)
            XCTAssertEqual(insertEvent.isCancelEvent, false)

            guard let info = insertEvent.info, let breakDuration = info.breakDuration else {
                XCTAssert(false)
                return
            }

            XCTAssertEqual(info.isOutOfNetwork, true)
            XCTAssertEqual(info.shouldSpliceImmediately, false)
            XCTAssertEqual(breakDuration.autoReturn, true)
            XCTAssertEqual(breakDuration.duration, 5400000)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 0)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 0)

        XCTAssertEqual(timeSignal.crc32, "0xA1E8A48A")
        XCTAssertNil(timeSignal.ecrc32)
    }

    let validSpliceInsertInCue = "/DAgAAAAAAAAAP/wDwUAAAPvf0//ahTGjwAAAAAAALda4HI="
    func testValidSpliceInsertInCue() {
        let timeSignal = try! converter.parseFrom(base64String: validSpliceInsertInCue)

        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 32)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 0)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 15)
        XCTAssertEqual(timeSignal.spliceCommandType, 5)
        switch timeSignal.spliceCommand {
        case .insert(insertEvent: let insertEvent):
            XCTAssertEqual(insertEvent.id, 1007)
            XCTAssertEqual(insertEvent.isCancelEvent, false)

            guard let info = insertEvent.info else {
                XCTAssert(false)
                return
            }

            XCTAssertEqual(info.isOutOfNetwork, false)
            XCTAssertEqual(info.shouldSpliceImmediately, false)
            XCTAssertEqual(info.spliceTime?.isTimeSpecified, true)
            XCTAssertEqual(info.spliceTime?.ptsTime, 6074713743)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 0)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 0)

        XCTAssertEqual(timeSignal.crc32, "0xB75AE072")
        XCTAssertNil(timeSignal.ecrc32)
    }


    let validTimeSegMidAdsTiCue = "/DA9AAAAAAAAAACABQb+0fha8wAnAiVDVUVJSAAAv3/PAAD4+mMNEQ4FTEEzMDkICAAAAAAuU4SBNAAAPIaCPw=="
    func testValidTimeSignalCue() {
        let timeSignal = try! converter.parseFrom(base64String: validTimeSegMidAdsTiCue)
        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 61)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 0)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0x8")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 3522714355)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 39)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 37)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 1207959743)
            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)

            guard let restrictions = additionalInfo.restrictions else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(restrictions.isWebDeliveryAllowed, false)
            XCTAssertEqual(restrictions.isNotRegionallyBlackedOut, true)
            XCTAssertEqual(restrictions.isArchiveAllowed, true)
            XCTAssertEqual(restrictions.deviceRestrictions, DeviceRestrictions.noRestrictions)

            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertEqual(additionalInfo.segmentationDuration, 16317027)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 13)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "MID()")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "Multiple UPID types structure as defined in section 10.3.3.4.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .MID(let upids):
                guard let firstUPID = upids.first?.info else { XCTFail("Expected a 2 element UPID array"); return }
                switch firstUPID {
                case .ADS(let string):
                    XCTAssertEqual(string, "LA309")
                default:
                    XCTFail("Incorrect upid type: \(firstUPID)")
                }

                guard let secondUPID = upids.last?.info else { XCTFail("Expected a 2 element UPID array"); return }
                switch secondUPID {
                case .TI(let string):
                    XCTAssertEqual(string, "0x000000002E538481")
                default:
                    XCTFail("Incorrect upid type: \(secondUPID)")
                }

            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .providerPlacementOpportunityStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)
            XCTAssertEqual(additionalInfo.subSegmentNumber, 0)
            XCTAssertEqual(additionalInfo.subSegmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0x3C86823F")
        XCTAssertNil(timeSignal.ecrc32)
    }

    let validSpliceAvailCue = "/DAvAAAAAAAAAP///wViAAWKf+//CXVCAv4AUmXAAzUAAAAKAAhDVUVJADgyMWLvc/g="
    func testValidSpliceAvailCue() {
        let spliceAvail = try! converter.parseFrom(base64String: validSpliceAvailCue)
        XCTAssertEqual(spliceAvail.tableID, 252)
        XCTAssertEqual(spliceAvail.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(spliceAvail.isPrivateIndicatorOn, false)
        XCTAssertEqual(spliceAvail.sectionLength, 47)
        XCTAssertEqual(spliceAvail.protocolVersion, 0)
        XCTAssertEqual(spliceAvail.hasEncryptedPacket, false)
        XCTAssertEqual(spliceAvail.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(spliceAvail.ptsAdjustment, 0)
        XCTAssertEqual(spliceAvail.cwIndex, 0)
        XCTAssertEqual(spliceAvail.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(spliceAvail.spliceCommandLength, 20) // The value of 4095 means it is legacy code and should be read as 20 bytes
        XCTAssertEqual(spliceAvail.spliceCommandType, 5)
        switch spliceAvail.spliceCommand {
        case .insert(insertEvent: let insertEvent):
            XCTAssertEqual(insertEvent.id, 1644168586)
            XCTAssertEqual(insertEvent.isCancelEvent, false)

            guard let info = insertEvent.info else {
                XCTAssert(false)
                return
            }

            XCTAssertEqual(info.isOutOfNetwork, true)
            XCTAssertEqual(info.shouldSpliceImmediately, false)

            guard let spliceTime = info.spliceTime else {
                XCTAssert(false)
                return
            }

            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 4453646850)

            XCTAssertNil(info.components)

            guard let breakDuration = info.breakDuration else {
                XCTAssert(false)
                return
            }

            XCTAssertEqual(breakDuration.autoReturn, true)
            XCTAssertEqual(breakDuration.duration, 5400000)

            XCTAssertEqual(info.uniqueProgramID, 821)
            XCTAssertEqual(info.availableNumber, 0)
            XCTAssertEqual(info.availablesExpected, 0)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(spliceAvail.descriptorLoopLength, 10)
        XCTAssertEqual(spliceAvail.spliceDescriptors.count, 1)
        switch spliceAvail.spliceDescriptors.first! {
        case .avail(info: let availInfo):
            XCTAssertEqual(availInfo.tag, 0)
            XCTAssertEqual(availInfo.length, 8)
            XCTAssertEqual(availInfo.identifier, 1129661769)
            XCTAssertEqual(availInfo.providerAvailID, 3682865)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(spliceAvail.crc32, "0x62EF73F8")
        XCTAssertNil(spliceAvail.ecrc32)
    }

    let validTimeSigPlacOppStart = "0xFC3034000000000000FFFFF00506FE72BD0050001E021C435545494800008E7FCF0001A599B00808000000002CA0A18A3402009AC9D17E"
    func testValidTimeSigPlacOppStart() {
        let spliceAvail = try! converter.parseFrom(hexString: validTimeSigPlacOppStart)
        XCTAssertEqual(spliceAvail.tableID, 252)
        XCTAssertEqual(spliceAvail.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(spliceAvail.isPrivateIndicatorOn, false)
        XCTAssertEqual(spliceAvail.sectionLength, 52)
        XCTAssertEqual(spliceAvail.protocolVersion, 0)
        XCTAssertEqual(spliceAvail.hasEncryptedPacket, false)
        XCTAssertEqual(spliceAvail.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(spliceAvail.ptsAdjustment, 0)
        XCTAssertEqual(spliceAvail.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(spliceAvail.spliceCommandLength, 0x5)
        XCTAssertEqual(spliceAvail.spliceCommandType, 6)
        switch spliceAvail.spliceCommand {
        case .timeSignal(spliceTime: let timeSignal):
            XCTAssertEqual(timeSignal.isTimeSpecified, true)
            XCTAssertEqual(timeSignal.ptsTime, 1924989008)
        default:
            XCTAssert(false)
        }

        XCTAssertEqual(spliceAvail.descriptorLoopLength, 30)
        XCTAssertEqual(spliceAvail.spliceDescriptors.count, 1)
        switch spliceAvail.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 28)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 1207959694)
            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)

            guard let restrictions = additionalInfo.restrictions else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(restrictions.isWebDeliveryAllowed, false)
            XCTAssertEqual(restrictions.isNotRegionallyBlackedOut, true)
            XCTAssertEqual(restrictions.isArchiveAllowed, true)
            XCTAssertEqual(restrictions.deviceRestrictions, DeviceRestrictions.noRestrictions)
            XCTAssertNil(additionalInfo.pidComponents)

            XCTAssertEqual(additionalInfo.segmentationDuration, 27630000)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 8)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "TI")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "AiringID (Formerly Turner ID), used to indicate a specific airing of a program that is unique within a network.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .TI(let string):
                XCTAssertEqual(string, "0x000000002CA0A18A")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .providerPlacementOpportunityStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 2)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(spliceAvail.crc32, "0x9AC9D17E")
        XCTAssertNil(spliceAvail.ecrc32)
    }

    let cueWithArrayOfUPID = "/DCxAAAAAAAAAP/wEAUAAAAAf78A/gAAADwAAAAAAJACjkNVRUkAAAAAf/8AABEqiA16Dh4zMDMwMzAzMTM0MzQzNjM5MzIzNzMxMzgzOTMyMzYOWDQzNzU2NTU0Nzk3MDY1M0Q3MzZFNjY1Rjc0NkY3OTZGNzQ2MTVGNkU2NjZDNUYzMjNCNEI2NTc5M0Q3MDYyM0I1NjYxNkM3NTY1M0Q3NDZGNzk2Rjc0NjE2AQHypciA"
    func testCueWithArrayOfUPID() {
        let timeSignal = try! converter.parseFrom(base64String: cueWithArrayOfUPID)
        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 177)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 0)
        XCTAssertEqual(timeSignal.cwIndex, 0)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 16)
        XCTAssertEqual(timeSignal.spliceCommandType, 5)
        
        switch timeSignal.spliceCommand {
        case .insert(let event):
            XCTAssertFalse(event.isCancelEvent)
            XCTAssertEqual(event.id, 0)
        default:
            XCTFail("Expected the splice command to be a splice insert")
        }

        XCTAssertEqual(timeSignal.descriptorLoopLength, 144)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 142)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 0)
            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)
            XCTAssertNil(additionalInfo.restrictions)
            XCTAssertNil(additionalInfo.pidComponents)
            XCTAssertEqual(additionalInfo.segmentationDuration, 1125000)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 13)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "MID()")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "Multiple UPID types structure as defined in section 10.3.3.4.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .MID(let upids):
                XCTAssertEqual(upids.count, 2)
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .distributorPlacementOpportunityStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 1)
            XCTAssertEqual(additionalInfo.segmentsExpected, 1)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0xF2A5C880")
        XCTAssertNil(timeSignal.ecrc32)
    }
    
    let privateUPIDStructure = "/DCVAAAAAsrbAP/wBQb/mbLvEAB/AntDVUVJAAAAAn/TAACkydoMZ05CQ1V7J2Fzc2V0SWQnOidwZWFjb2NrXzE1Mzk0MycsJ2N1ZURhdGEnOnsnY3VlVHlwZSc6J2FmZmlsaWF0ZV9icmVhaycsJ2tleSc6J3BiJywndmFsdWUnOidhZmZpbGlhdGUnfX00AAAAAJYJLnk="
    func testPrivateUPIDStructure() {
        
        let timeSignal = try! converter.parseFrom(base64String: privateUPIDStructure)
        XCTAssertEqual(timeSignal.tableID, 252)
        XCTAssertEqual(timeSignal.isSectionSyntaxIndicatorOn, false)
        XCTAssertEqual(timeSignal.isPrivateIndicatorOn, false)
        XCTAssertEqual(timeSignal.sectionLength, 149)
        XCTAssertEqual(timeSignal.protocolVersion, 0)
        XCTAssertEqual(timeSignal.hasEncryptedPacket, false)
        XCTAssertEqual(timeSignal.encryptionAlgorithm, .noAlgorithm)
        XCTAssertEqual(timeSignal.ptsAdjustment, 183003)
        XCTAssertEqual(timeSignal.cwIndex, 0)
        XCTAssertEqual(timeSignal.tier.hexRepresentation, "0xFFF")

        XCTAssertEqual(timeSignal.spliceCommandLength, 5)
        XCTAssertEqual(timeSignal.spliceCommandType, 6)
        switch timeSignal.spliceCommand {
        case .timeSignal(spliceTime: let spliceTime):
            XCTAssertEqual(spliceTime.isTimeSpecified, true)
            XCTAssertEqual(spliceTime.ptsTime, 6873607952)
        default:
            XCTAssert(false)
        }
        
        XCTAssertEqual(timeSignal.descriptorLoopLength, 127)
        XCTAssertEqual(timeSignal.spliceDescriptors.count, 1)
        switch timeSignal.spliceDescriptors.first! {
        case .segmentation(info: let info):
            guard let additionalInfo = info.additionalInfo else {
                XCTAssert(false)
                return
            }
            XCTAssertEqual(info.tag, 2)
            XCTAssertEqual(info.length, 123)
            XCTAssertEqual(info.identifier, 1129661769)
            XCTAssertEqual(info.eventID, 2)
            XCTAssertEqual(additionalInfo.isProgramSegmentedMode, true)
            XCTAssertEqual(additionalInfo.hasSegmentationDuration, true)
            XCTAssertNotNil(additionalInfo.restrictions)
            XCTAssertEqual(additionalInfo.restrictions?.isWebDeliveryAllowed, true)
            XCTAssertEqual(additionalInfo.restrictions?.isNotRegionallyBlackedOut, false)
            XCTAssertEqual(additionalInfo.restrictions?.isArchiveAllowed, false)
            XCTAssertEqual(additionalInfo.restrictions?.deviceRestrictions, DeviceRestrictions.noRestrictions)
            
            XCTAssertNil(additionalInfo.pidComponents)

            XCTAssertEqual(additionalInfo.segmentationDuration, 10799578)
            XCTAssertEqual(additionalInfo.segmentationUPID.type, 12)
            XCTAssertEqual(additionalInfo.segmentationUPID.name, "MPU()")
            XCTAssertEqual(additionalInfo.segmentationUPID.description, "Managed Private UPID structure as defined in section 10.3.3.3.")

            guard let upidInfo = additionalInfo.segmentationUPID.info else {
                XCTAssert(false)
                return
            }

            switch upidInfo {
            case .MPU(let string):
                XCTAssertEqual(string, "NBCU{\'assetId\':\'peacock_153943\',\'cueData\':{\'cueType\':\'affiliate_break\',\'key\':\'pb\',\'value\':\'affiliate\'}}")
            default:
                XCTFail("Incorrect upid type: \(upidInfo)")
            }

            XCTAssertEqual(additionalInfo.segmentationTypeID, .providerPlacementOpportunityStart)
            XCTAssertEqual(additionalInfo.segmentNumber, 0)
            XCTAssertEqual(additionalInfo.segmentsExpected, 0)
            XCTAssertEqual(additionalInfo.subSegmentNumber, 0)
            XCTAssertEqual(additionalInfo.subSegmentsExpected, 0)

        default:
            XCTAssert(false)
        }

        XCTAssertEqual(timeSignal.crc32, "0x96092E79")
        XCTAssertNil(timeSignal.ecrc32)
    }
}
