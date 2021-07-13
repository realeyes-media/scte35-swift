//
//  EncryptionAlgorithm.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/30/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

public enum EncryptionAlgorithm {
    case noAlgorithm
    case desECBMode
    case desCBCMode
    case tripleDesEDE3
    case reserved
    case userPrivate
}
