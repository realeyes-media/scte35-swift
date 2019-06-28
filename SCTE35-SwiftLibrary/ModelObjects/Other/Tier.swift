//
//  Tier.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/30/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public struct Tier {
    let value: Int
    var hexRepresentation: String {
        return "0x" + String(value, radix: 16).uppercased()
    }
}
