//
//  ISAN.swift
//  
//
//  Created by Jonathan Bachmann on 4/27/22.
//

import Foundation

struct ISO7064 {
    static let alphanumericCharacterSet: [Character] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"
    ]

    private static let hexCharSet: [Character] = Array(alphanumericCharacterSet[0..<16])

    // calculate the alphanumeric check character from the hex
    static func calculateMod3637CheckCharacter(fromHexadecimals hexaDecimals: [Character]) -> Character? {
        var decimals = [Int]()
        for hexChar in hexaDecimals {
            guard let index: Int = hexCharSet.firstIndex(of: Character(hexChar.uppercased())) else { return nil }
            decimals.append(index)
        }
        return calculateMod3637CheckCharacter(fromDecimals: decimals)
    }

    // calculate the alphanumeric check character from the array of base 10 decimal values
    static func calculateMod3637CheckCharacter(fromDecimals decimals: [Int]) -> Character? {
        var adjustedProduct = ISO7064.calculateMod3637AdjustedProduct(with: decimals[0])
        for digit in decimals[1..<decimals.count] {
            adjustedProduct = ISO7064.calculateMod3637AdjustedProduct(with: digit, and: adjustedProduct)
        }

        let checkDigit = 37 - adjustedProduct
        guard checkDigit <= alphanumericCharacterSet.count else { return nil }

        return alphanumericCharacterSet[checkDigit]
    }

    private static func calculateMod3637AdjustedProduct(with decimal: Int, and lastAdjustedProduct: Int? = nil) -> Int {
        var intermediateSum = decimal + (lastAdjustedProduct ?? 36)
        intermediateSum = (intermediateSum >= 36) ? intermediateSum - 36 : intermediateSum
        intermediateSum = (intermediateSum == 0) ? 36 : intermediateSum
        var adjustedProduct = intermediateSum * 2
        adjustedProduct = (adjustedProduct >= 37) ? adjustedProduct - 37 : adjustedProduct
        return adjustedProduct
    }
}
