//
//  SCTE35Converter.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/29/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct SCTE35Converter {
    private let minimumBitsInSpliceInfoSection = 200

    /// TODO: - Description of function
    /// - Throws: An error of type `SCTE35ParsingError`
    public func parseFrom(base64String: String) throws -> SpliceInfoSection {
        guard let data = Data(base64Encoded: base64String) else {
            throw SCTE35ParsingError.invalidBase64String
        }

        let bitsArray = BitConverter.bits(fromData: data)
        guard bitsArray.count >= minimumBitsInSpliceInfoSection else {
            throw SCTE35ParsingError.base64StringTooShort
        }

        guard hasValidTableID(bitsArray) else {
            throw SCTE35ParsingError.invalidTableID
        }

        let isSectionSyntaxIndicatorOn = getSectionSyntaxIndicatorOn(bitsArray)
        let isPrivateIndicatorOn = getPrivateIndicatorOn(bitsArray)

        let previousSectionLength = 24 // 3 bytes of info up to this point
        let remainingSectionLength = getSectionLength(bitsArray)
        let totalNumberOfBytes = previousSectionLength + (remainingSectionLength * 8)

        guard totalNumberOfBytes == bitsArray.count && remainingSectionLength <= 4093 else {
            throw SCTE35ParsingError.sectionLengthIncorrect
        }

        let protocolVersion = getProtocolVersion(bitsArray)
        if protocolVersion != 0 {
            throw SCTE35ParsingError.invalidProtocolVersion
        }

        let isEncryptedPacketOn = getIsEncryptedPacketOn(bitsArray)

        guard let encryptionAlgorithm = getEncryptionAlgorithm(bitsArray) else {
            throw SCTE35ParsingError.unknownEncryptionAlgorithm
        }

        let ptsAdjustment = getPTSAdjustment(bitsArray)
        let cwIndex = getCWIndex(bitsArray)
        let tier = getTier(bitsArray)

        let spliceCommandLengthInBytes = getSpliceCommandLengthInBytes(bitsArray)
        let spliceCommandType = getSpliceCommandType(bitsArray)
        let spliceCommandInfo = getSpliceCommandRelevantBitsAndNextBitLocation(bitsArray, spliceCommandLengthInBytes: spliceCommandLengthInBytes)
        let spliceCommandRelevantBits = spliceCommandInfo.spliceCommandBits
        let descriptorInfoStartingIndex = spliceCommandInfo.nextBitLocation
        let spliceCommand: SpliceCommand
        do {
            spliceCommand = try SpliceCommand(spliceCommandType: spliceCommandType, relevantBits: spliceCommandRelevantBits)
        } catch {
            throw error
        }

        guard descriptorInfoStartingIndex + 48 <= bitsArray.count else {
            // Double-checking, but this code should never run
            // since a length check was implemented above
            throw SCTE35ParsingError.sectionLengthIncorrect
        }

        let descriptorInfo = getDescriptorInfo(bitsArray, descriptorLoopLengthStartingLocation: descriptorInfoStartingIndex)
        let allDescriptorsBits: [Bit] = descriptorInfo.descriptorLoopBits

        let spliceDescriptors: [SpliceDescriptor]
        do {
            spliceDescriptors = try getDescriptorsFrom(allDescriptorsBits)
        } catch {
            throw error
        }

        let crcStrings = getCRCs(bitsArray, isEncryptedPacketOn: isEncryptedPacketOn)

        return SpliceInfoSection(tableID: 252, isSectionSyntaxIndicatorOn: isSectionSyntaxIndicatorOn, isPrivateIndicatorOn: isPrivateIndicatorOn, sectionLength: remainingSectionLength, protocolVersion: protocolVersion, hasEncryptedPacket: isEncryptedPacketOn, encryptionAlgorithm: encryptionAlgorithm, ptsAdjustment: ptsAdjustment, cwIndex: cwIndex, tier: tier, spliceCommandLength: spliceCommandLengthInBytes, spliceCommandType: spliceCommandType, spliceCommand: spliceCommand, descriptorLoopLength: descriptorInfo.descriptorLoopLength, spliceDescriptors: spliceDescriptors, crc32: crcStrings.crc32, ecrc32: crcStrings.ecrc32)
    }

    /// TODO: - Description of function
    public func parseFrom(hexString: String) throws -> SpliceInfoSection {
        guard let base64String = BitConverter.convertToBase64String(hexString: hexString) else {
            throw SCTE35ParsingError.invalidHexString
        }

        do {
            return try parseFrom(base64String: base64String)
        } catch {
            throw error
        }
    }
}
