//
//  BitConverter.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/29/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

class BitConverter {
    /**
     Will return an array of 8 bits
     i.e. input = 15, output = [0, 0, 0, 0, 1, 1, 1, 1]
     */
    static func bits(from byte: UInt8) -> [Bit] {
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }

            byte >>= 1
        }
        return bits.reversed()
    }

    /**
     Will return an array of 16 bits
     i.e. input = 15, output = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1]
     */
    static func bits(from value: UInt16) -> [Bit] {
        var bits: [Bit] = []
        withUnsafeBytes(of: value) {
            for bite in $0.reversed() {
                bits.append(contentsOf: BitConverter.bits(from: bite))
            }
        }
        return bits
    }

    /**
     Will return an array of 32 bits
     i.e. input = 15, output =
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1]
     */
    static func bits(from value: UInt32) -> [Bit] {
        var bits: [Bit] = []
        withUnsafeBytes(of: value) {
            for bite in $0.reversed() {
                bits.append(contentsOf: BitConverter.bits(from: bite))
            }
        }
        return bits
    }

    /**
     Will return an array of `bitArraySize` bits
     i.e. value = 15, bitArraySize = 9, output = [0, 0, 0, 0, 0, 1, 1, 1, 1]

     If `bitArraySize` is smaller the maximum number of bits needed to represent
     `value`, the array of bits that represent `value` will be truncated to `bitArraySize` and
     the returned bit array cannot be converted back to `value`
     */
    static func bits(from value: Int, bitArraySize: Int) -> [Bit] {
        var bits: [Bit] = []
        withUnsafeBytes(of: value) {
            for bite in $0.reversed() {
                bits.append(contentsOf: BitConverter.bits(from: bite))
            }
        }
        return bits.suffix(bitArraySize)
    }

    static func bits(fromData data: Data) -> [Bit] {
        var bits: [Bit] = []
        for byte in data {
            let x = BitConverter.bits(from: byte)
            bits.append(contentsOf: x)
        }
        return bits
    }

    /**
     Convert bit array into a `Data` instance

     Bit array must be stored as most significant bit first

     This method will determine the endian-ness of the current system to ensure
     byte ordering is correct.
     */
    static func data(from bits: [Bit]) -> Data {
        var paddedBits = bits
        let bitRemainder = bits.count % 8
        if bitRemainder != 0 {
            paddedBits.insert(contentsOf: [Bit](repeating: .zero, count: 8 - bitRemainder), at: 0)
        }

        var data = Data(capacity: paddedBits.count/8)
        for index in stride(from: paddedBits.startIndex, to: paddedBits.endIndex, by: 8) {
            let bite = Array(paddedBits[index..<index+8])
            let uint8Val = UInt8(BitConverter.integer(fromBits: bite))
            if CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderBigEndian.rawValue) {
                data.append(uint8Val)
            } else if CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderLittleEndian.rawValue) {
                data.insert(uint8Val, at: 0)
            }
        }

        return data
    }

    static func integer(fromBits bits: [Bit]) -> Int {
        var multiplier = 1
        var total = 0
        var bits = bits

        while !bits.isEmpty {
            guard let bit = bits.popLast() else { continue }
            total += bit.rawValue * multiplier
            multiplier *= 2
        }

        return total
    }

    static func string(fromBits bits: [Bit]) -> String? {
        guard bits.count % 8 == 0 else { return nil }
        let count = bits.count

        let bytes = stride(from: 0, to: count, by: 8).map { (last) -> [Bit] in
            return Array(bits[last..<last+8])
        }

        var string: String = ""
        for byte in bytes {
            let intValueOfChar = integer(fromBits: byte)
            guard let uni = UnicodeScalar(intValueOfChar) else { return nil }
            let char = Character(uni)
            string.append(char)
        }

        return string
    }

    static func umidString(fromBits bits: [Bit]) -> String? {
        guard bits.count == 256 else { return nil }
        let nibbles = stride(from: 0, to: bits.count, by: 4).map { (last) -> [Bit] in
            return Array(bits[last..<last+4])
        }

        var stringToReturn = ""
        let finalIndex = nibbles.count - 1
        for (index, nibble) in nibbles.enumerated() {
            let intValue = BitConverter.integer(fromBits: nibble)
            let char = String(format: "%01X", intValue)
            stringToReturn.append(char)
            if index != 0 && index != finalIndex && index % 8 == 7 {
                stringToReturn.append(".")
            }
        }

        return stringToReturn
    }

    static func bits(fromUMID umid: String) -> [Bit]? {
        guard umid.replacingOccurrences(of: ".", with: "").count == 64 else { return nil}

        let hexParts = umid.split(separator: ".")
        guard hexParts.count == 8 else { return nil }

        var bits = [Bit]()
        for hexChar in hexParts {
            guard let integer = UInt32(hexChar, radix: 16) else {
                return nil
            }
            bits.append(contentsOf: BitConverter.bits(from: integer))
        }
        return bits
    }

    static func isanString(fromBits bits: [Bit]) -> String? {
        let containsVersion: Bool
        if bits.count == 96 {
            containsVersion = true
        } else if bits.count == 64 {
            containsVersion =  false
        } else {
            // number of bits does not represent a valid ISAN
            return nil
        }

        var isanIntegers = [Int]()
        for index in stride(from: bits.startIndex, to: bits.endIndex, by: 4) {
            let nibble = Array(bits[index..<index+4])
            let intValue = BitConverter.integer(fromBits: nibble)
            isanIntegers.append(intValue)
        }

        // There must always be a first check character for the root and episode segments
        guard let firstCheckChar: Character = ISO7064.calculateMod3637CheckCharacter(fromDecimals: Array(isanIntegers.prefix(16))) else { return nil }
        // If there is no version, there is no second check character
        let secondCheckChar: Character? = containsVersion ? ISO7064.calculateMod3637CheckCharacter(fromDecimals: isanIntegers) : nil

        // Build ISAN string without check chars
        var isanString = ""
        for (index, int) in isanIntegers.enumerated() {
            if index != 0 && index % 4 == 0 { isanString.append("-") }
            let char = String(format: "%01X", int)
            isanString.append(char)
        }

        // Add in check chars
        if !containsVersion {
            isanString.append("-\(firstCheckChar)")
        } else {
            let firstCheckDigitIndex = isanString.index(isanString.startIndex, offsetBy: 19)
            isanString.insert(contentsOf: "-\(firstCheckChar)", at: firstCheckDigitIndex)
            guard let theSecondCheckChar = secondCheckChar else { return nil }
            isanString.append("-\(theSecondCheckChar)")
        }

        return isanString
    }

    static func bits(fromIsan isan: String) -> [Bit]? {
        let containsVersion: Bool
        if isan.count == 33 {
            containsVersion = true
        } else if isan.count == 21 {
            containsVersion =  false
        } else {
            // character count does not meet requirements for ISAN string
            return nil
        }

        // remove check digits from isan string
        var isanHexDecimals = isan.replacingOccurrences(of: "-", with: "").dropLast() // dropLast removes the 2nd check digit
        if containsVersion {
            let firstCheckDigitIndex = isanHexDecimals.index(isanHexDecimals.startIndex, offsetBy: 16)
            isanHexDecimals.remove(at: firstCheckDigitIndex)
        }

        var bits = [Bit]()
        for hexVal in isanHexDecimals {
            guard let alphaNumCharVal = ISO7064.alphanumericCharacterSet.firstIndex(of: hexVal) else { return nil }
            bits.append(contentsOf: BitConverter.bits(from: alphaNumCharVal, bitArraySize: 4))
        }

        return bits
    }

    static func eidrString(fromBits bits: [Bit]) -> String? {
        guard bits.count == 96 else { return nil }
        let firstTwoBytes = Array(bits[0..<16])
        let subPrefix = BitConverter.integer(fromBits: firstTwoBytes)

        var eidrIntegers = [Int]()
        for index in stride(from: bits.startIndex.advanced(by: 16), to: bits.endIndex, by: 4) {
            let nibble = Array(bits[index..<index+4])
            let intValue = BitConverter.integer(fromBits: nibble)
            eidrIntegers.append(intValue)
        }

        guard let checkChar = ISO7064.calculateMod3637CheckCharacter(fromDecimals: eidrIntegers) else { return nil }

        // Build EIDR string
        var eidrString = "10.\(subPrefix)/"
        for (index, int) in eidrIntegers.enumerated() {
            if index != 0 && index % 4 == 0 { eidrString.append("-") }
            let char = String(format: "%01X", int)
            eidrString.append(char)
        }
        eidrString.append("-\(checkChar)")

        return eidrString
    }

    static func bits(fromEidr eidr: String) -> [Bit]? {
        let strippedString = eidr.replacingOccurrences(of: "10.", with: "")
        let eidrParts = strippedString.split(separator: "/")
        guard
            eidrParts.count == 2,
            let subPrefix = eidrParts.first,
            let subPrefixUInt16 = UInt16(subPrefix, radix: 10),
            let suffix = eidrParts.last
        else { return nil }

        // get only the hex characters of the DOI suffix, removing the trailing check char
        let eidrHexChars = suffix.replacingOccurrences(of: "-", with: "").dropLast()

        var bits = BitConverter.bits(from: subPrefixUInt16)
        for hexVal in eidrHexChars {
            guard let alphaNumCharVal = ISO7064.alphanumericCharacterSet.firstIndex(of: hexVal) else { return nil }
            bits.append(contentsOf: BitConverter.bits(from: alphaNumCharVal, bitArraySize: 4))
        }

        guard bits.count == 96 else { return nil }

        return bits
    }

    static func hexString(fromBits bits: [Bit]) -> String? {
        guard bits.count % 4 == 0 else { return nil }

        var hexString = ""
        for index in stride(from: bits.startIndex, to: bits.endIndex, by: 4) {
            let nibble = Array(bits[index..<index+4])
            let intValue = BitConverter.integer(fromBits: nibble)
            let char = String(format: "%01X", intValue)
            hexString.append(char)
        }
        return "0x\(hexString)"
    }

    static func bits(fromHexString hexString: String) -> [Bit]? {
        let hexCharSet = "0123456789ABCDEF"
        let rawHexString = hexString.uppercased().replacingOccurrences(of: "0X", with: "")
        var bits = [Bit]()
        for char in rawHexString {
            guard
                hexCharSet.contains(char),
                let intValue = Int(String(char), radix: 16)
            else { return nil }
            bits.append(contentsOf: BitConverter.bits(from: intValue, bitArraySize: 4))
        }
        return bits
    }

    static func convertToBase64String(hexString: String) -> String? {
        var hexString = hexString
        if let index = hexString.firstIndex(of: "x") {
            hexString.removeSubrange(hexString.startIndex...index)
        }

        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0..<length {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        return data.base64EncodedString()
    }

    // Advertising Digital Identification, LLC Group.  12 characters; 4 alpha characters (company ID prefix)
    //  followed by 8 alpha numeric characters
    static func adIdString(from bits: [Bit]) -> String? {
        guard
            let decodedString = BitConverter.string(fromBits: bits),
            decodedString.count == 12
        else {
            return nil
        }

        // Check that string follows TID (Tribune Media Systems Program identifier) format rules
        for (index, char) in decodedString.enumerated() {
            switch index {
            case 0..<4:
                if !char.isLetter { return nil }
            case 2..<12:
                if !char.isLetter && !char.isNumber { return nil }
            default:
                return nil
            }
        }

        return decodedString
    }

    // Tribune Media Systems Program ID.  12 characters; 2 alpha characters followed by 10 numbers
    static func tidString(from bits: [Bit]) -> String? {
        guard
            let decodedString = BitConverter.string(fromBits: bits),
            decodedString.count == 12
        else {
            return nil
        }

        // Check that string follows TID (Tribune Media Systems Program identifier) format rules
        for (index, char) in decodedString.enumerated() {
            switch index {
            case 0..<2:
                if !char.isLetter { return nil }
            case 2..<12:
                if !char.isNumber { return nil }
            default:
                return nil
            }
        }

        return decodedString
    }

    // CableLabs metadata identifier
    static func adiString(from bits: [Bit]) -> String? {
        guard let decodedString = BitConverter.string(fromBits: bits) else { return nil }

        // Extract the parts of the adi UPID and check that they conform to some of the rules specified in the `CableLabs metadata identifier` section
        let parts = decodedString.components(separatedBy: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        guard
            parts.count == 2,
            let elementString = parts.first,
            AdiElement(rawValue: elementString) != nil,
            let id = parts.last,
            id.contains("/")
        else { return nil }

        return id

        // this enum is used as a way to check that the element part of the ADI UPID is valid
        enum AdiElement: String {
            case preview = "PREVIEW"
            case MPEG2HD = "MPEG2HD"
            case MPEG2SD = "MPEG2SD"
            case AVCHD = "AVCHD"
            case AVCSD = "AVCSD"
            case HEVCHD = "HEVCHD"
            case HEVCSD = "HEVCSD"
            case signal = "SIGNAL"
            case placementOpportunity = "PO"
            case blackout = "BLACKOUT"
            case other = "OTHER"
        }
    }
}
