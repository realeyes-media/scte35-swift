//
//  Helpers.swift
//  
//
//  Created by Jonathan Bachmann on 4/29/22.
//

import Foundation
@testable import SCTE35

func getBits(from string: String) -> [Bit]? {
    var bits = [Bit]()
    for b in string {
        guard let bit = Bit(rawValue: (b == "1" ? 1 : 0)) else { return nil }
        bits.append(bit)
    }
    return bits
}
