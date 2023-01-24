//
//  Bit.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/29/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

enum Bit: Int, CustomStringConvertible {
    case zero = 0
    case one = 1

    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

extension Bit: Equatable {}

typealias BitCodable = BitEncodable & BitDecodable

protocol BitDecodable {
    init?(from bits: [Bit])
}

protocol BitEncodable {
    func encode() throws -> [Bit]
}
