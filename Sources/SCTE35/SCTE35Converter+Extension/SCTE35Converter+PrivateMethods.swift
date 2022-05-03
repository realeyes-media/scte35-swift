//
//  SCTE35Converter+PrivateMethods.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/30/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

extension SCTE35Converter {
    func hasValidTableID(_ bitsArray: [Bit]) -> Bool {
        let tableIDLocation = 0...7
        let firstByte = Array(bitsArray[tableIDLocation])

        let validTableID: [Bit] = [.one, .one, .one, .one, .one, .one, .zero, .zero]
        return validTableID == firstByte
    }

    func getSectionSyntaxIndicatorOn(_ bitsArray: [Bit]) -> Bool {
        let sectionSyntaxIndicatorLocation = 8
        return bitsArray[sectionSyntaxIndicatorLocation] == .one
    }

    func getPrivateIndicatorOn(_ bitsArray: [Bit]) -> Bool {
        let privateIndicatorLocation = 9
        return bitsArray[privateIndicatorLocation] == .one
    }

    func getSectionLength(_ bitsArray: [Bit]) -> Int {
        let sectionLengthLocation = 12...23
        let sectionLengthBits = Array(bitsArray[sectionLengthLocation])
        return BitConverter.integer(fromBits: sectionLengthBits)
    }

    func getProtocolVersion(_ bitsArray: [Bit]) -> Int {
        let protocolVersionLocation = 24...31
        let protocolVersionBits = Array(bitsArray[protocolVersionLocation])
        return BitConverter.integer(fromBits: protocolVersionBits)
    }

    func getIsEncryptedPacketOn(_ bitsArray: [Bit]) -> Bool {
        let encryptedPacketLocation = 32
        return bitsArray[encryptedPacketLocation] == .one
    }

    func getEncryptionAlgorithm(_ bitsArray: [Bit]) -> EncryptionAlgorithm? {
        let encryptionAlgorithmLocation = 33...38
        let encriptionAlgorithmBits = Array(bitsArray[encryptionAlgorithmLocation])
        let sumOfBits = BitConverter.integer(fromBits: encriptionAlgorithmBits)

        let algorithm: EncryptionAlgorithm?
        switch sumOfBits {
        case 0:
            algorithm = .noAlgorithm
        case 1:
            algorithm = .desECBMode
        case 2:
            algorithm = .desCBCMode
        case 3:
            algorithm = .tripleDesEDE3
        case 4...31:
            algorithm = .reserved
        case 32...63:
            algorithm = .userPrivate
        default:
            algorithm = nil
        }
        return algorithm
    }

    func getPTSAdjustment(_ bitsArray: [Bit]) -> Int {
        let ptsAdjustmentLocation = 39...71
        let ptsAdjustmentBits = Array(bitsArray[ptsAdjustmentLocation])
        return BitConverter.integer(fromBits: ptsAdjustmentBits)
    }

    func getCWIndex(_ bitsArray: [Bit]) -> Int {
        let cwIndexLocation = 72...79
        let cwIndexBits = Array(bitsArray[cwIndexLocation])
        return BitConverter.integer(fromBits: cwIndexBits)
    }

    func getTier(_ bitsArray: [Bit]) -> Tier {
        let tierLocation = 80...91
        let tierBits = Array(bitsArray[tierLocation])
        let sum = BitConverter.integer(fromBits: tierBits)
        return Tier(value: sum)
    }

    func getSpliceCommandLengthInBytes(_ bitsArray: [Bit]) -> Int {
        let spliceCommandLengthLocation = 92...103
        let spliceCommandLengthBits = Array(bitsArray[spliceCommandLengthLocation])
        let sum = BitConverter.integer(fromBits: spliceCommandLengthBits)
        // if bits are all 1s (0xFFF), then it's legacy code which
        // always uses 20 bytes for the splice command
        return sum == 0xFFF ? 20 : sum
    }

    func getSpliceCommandType(_ bitsArray: [Bit]) -> Int {
        let spliceCommandTypeLocation = 104...111
        let spliceCommandTypeBits = Array(bitsArray[spliceCommandTypeLocation])
        return BitConverter.integer(fromBits: spliceCommandTypeBits)
    }

    func getSpliceCommandRelevantBitsAndNextBitLocation(_ bitsArray: [Bit], spliceCommandLengthInBytes: Int) -> (spliceCommandBits: [Bit], nextBitLocation: Int) {
        let spliceCommandLengthInBits = spliceCommandLengthInBytes * 8
        let spliceCommandRelevantBitsLocation = 112..<(112+spliceCommandLengthInBits)
        return (Array(bitsArray[spliceCommandRelevantBitsLocation]), 112+spliceCommandLengthInBits)
    }

    func getDescriptorInfo(_ bitsArray: [Bit], descriptorLoopLengthStartingLocation: Int) -> (descriptorLoopLength: Int, descriptorLoopBits: [Bit]) {
        let startIndex = descriptorLoopLengthStartingLocation
        let endIndex = descriptorLoopLengthStartingLocation + 16
        let descriptorLoopRange = startIndex..<endIndex
        let descriptorLoopLength = BitConverter.integer(fromBits: Array(bitsArray[descriptorLoopRange]))

        let descriptorLoopRelevantBitsRange = endIndex..<(endIndex + descriptorLoopLength*8)
        let descriptorLoopBits: [Bit] = Array(bitsArray[descriptorLoopRelevantBitsRange])
        return (descriptorLoopLength, descriptorLoopBits)
    }

    /// - Throws: An error of type `SCTE35ParsingError`
    func getDescriptorsFrom(_ relevantBits: [Bit]) throws -> [SpliceDescriptor] {
        if relevantBits.count == 0 { return [] }
        var bits = relevantBits
        guard bits.count >= 16 else {
            throw SCTE35ParsingError.unableToParseDescriptor(type: DescriptorType.unknown)
        }

        var descriptors = [SpliceDescriptor]()
        while !bits.isEmpty {
            // Get the descriptor tag and length that are the first 2 bytes of each SpliceDescriptor
            // Use that information to create the next descriptor in the switch statement below
            let descriptorTagRange = 0..<8
            let descriptorTagInt = BitConverter.integer(fromBits: Array(bits[descriptorTagRange]))
            let descriptorNumberOfBytesRange = 8..<16
            let lengthInBytes = BitConverter.integer(fromBits: Array(bits[descriptorNumberOfBytesRange]))
            let numberOfBitsToFollow = 8 * lengthInBytes
            bits.removeSubrange(0..<16)

            // Grab the bits that will hold the additional information about the SpliceDescriptor
            let nextDescriptorsBitsRange = 0..<numberOfBitsToFollow
            let nextDescriptorsBits = Array(bits[nextDescriptorsBitsRange])
            bits.removeSubrange(nextDescriptorsBitsRange)
            
            // If `nextDescriptorsBits.isEmpty` this could just be an descrepency between `splice_descriptor_loop_length` and `descriptor_length` so just continue.
            guard !nextDescriptorsBits.isEmpty else { continue }
            
            switch descriptorTagInt {
            case 0x00:
                guard let availInfo = AvailInfo(tag: descriptorTagInt, length: lengthInBytes, relevantBits: nextDescriptorsBits) else {
                    throw SCTE35ParsingError.unableToParseDescriptor(type: DescriptorType.avail)
                }
                descriptors.append(SpliceDescriptor.avail(info: availInfo))
            case 0x01:
                guard let dtmfInfo = DTMFInfo(tag: descriptorTagInt, length: lengthInBytes, relevantBits: nextDescriptorsBits) else {
                    throw SCTE35ParsingError.unableToParseDescriptor(type: DescriptorType.dtmf)
                }
                descriptors.append(SpliceDescriptor.dtmf(info: dtmfInfo))
            case 0x02:
                guard let segmentationInfo = SegmentationInfo(tag: descriptorTagInt, length: lengthInBytes, relevantBits: nextDescriptorsBits) else {
                    throw SCTE35ParsingError.unableToParseDescriptor(type: DescriptorType.segmentation)
                }
                descriptors.append(SpliceDescriptor.segmentation(info: segmentationInfo))
            case 0x03:
                guard let timeInfo = TimeInfo(tag: descriptorTagInt, length: lengthInBytes, relevantBits: nextDescriptorsBits) else {
                    throw SCTE35ParsingError.unableToParseDescriptor(type: DescriptorType.time)
                }
                descriptors.append(SpliceDescriptor.time(info: timeInfo))
            case 0x04:
                guard let audioInfo = AudioInfo(tag: descriptorTagInt, length: lengthInBytes, relevantBits: nextDescriptorsBits) else {
                    throw SCTE35ParsingError.unableToParseDescriptor(type: DescriptorType.audio)
                }
                descriptors.append(SpliceDescriptor.audio(info: audioInfo))
            default:
                // Reserved for future SCTE splice_descriptors
                continue
            }
        }
        return descriptors
    }

    func getCRCs(_ bitsArray: [Bit], isEncryptedPacketOn: Bool) throws -> (crc32: String, ecrc32: String?) {
        let crc32EndLocation = bitsArray.count
        let crc32StartLocation = crc32EndLocation - 32
        let crcRange = crc32StartLocation..<crc32EndLocation
        let crc32Bits = Array(bitsArray[crcRange])
        guard let crc32 = BitConverter.hexString(fromBits: crc32Bits) else { throw SCTE35ParsingError.couldNotDecodeBitsToExpectedType }

        let ecrc32: String?
        if isEncryptedPacketOn {
            let ecrc32EndLocation = crc32StartLocation
            let ecrc32StartLocation = ecrc32EndLocation - 32
            let ecrcRange = ecrc32StartLocation..<ecrc32EndLocation
            let ecrc32Bits = Array(bitsArray[ecrcRange])
            ecrc32 = BitConverter.hexString(fromBits: ecrc32Bits)
        } else {
            ecrc32 = nil
        }

        return (crc32, ecrc32)
    }
}
