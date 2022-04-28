//
//  ISAN.swift
//  
//
//  Created by Jonathan Bachmann on 4/27/22.
//

import Foundation

struct ISAN {
    static let alphanumericChars: [Character] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"
    ]

    static func calculateMod3637CheckCharacter(from digits: [Int]) -> Character? {
        var adjustedProduct = ISAN.calculateMod3637AdjustedProduct(with: digits[0])
        for digit in digits[1..<digits.count] {
            adjustedProduct = ISAN.calculateMod3637AdjustedProduct(with: digit, and: adjustedProduct)
        }

        let checkDigit = 37 - adjustedProduct
        guard checkDigit <= alphanumericChars.count else { return nil }

        return alphanumericChars[checkDigit]
    }

    private static func calculateMod3637AdjustedProduct(with digit: Int, and lastAdjustedProduct: Int? = nil) -> Int {
        var intermediateSum = digit + (lastAdjustedProduct ?? 36)
        intermediateSum = (intermediateSum >= 36) ? intermediateSum - 36 : intermediateSum
        intermediateSum = (intermediateSum == 0) ? 36 : intermediateSum
        var adjustedProduct = intermediateSum * 2
        adjustedProduct = (adjustedProduct >= 37) ? adjustedProduct - 37 : adjustedProduct
        return adjustedProduct
    }
}
