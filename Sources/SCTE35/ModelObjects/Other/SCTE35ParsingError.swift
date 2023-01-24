//
//  SCTE35ParsingError.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/30/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public enum SCTE35ParsingError: Error {
    case invalidBase64String
    case base64StringTooShort
    case invalidTableID
    case sectionLengthIncorrect
    case invalidProtocolVersion
    case unknownEncryptionAlgorithm
    case invalidSpliceCommandRange
    case invalidSpliceCommandType
    case unableToCreateSpliceCommand(type: CommandType)
    case unableToParseDescriptor(type: DescriptorType)
    case invalidHexString
    case invalidStringAsUtf8
    case couldNotDecodeBitsToExpectedType
}

public enum CommandType {
    case schedule
    case insert
    case timeSignal
    case bandwidthReservation
}

public enum DescriptorType {
    case avail
    case dtmf
    case segmentation
    case time
    case audio
    case unknown
}
