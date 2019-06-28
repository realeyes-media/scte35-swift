//
//  SpliceDescriptor.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 6/3/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// The splice_descriptor is a prototype for adding new fields to the splice_info_section. All descriptors included use the same syntax for the first six bytes. In order to allow private information to be added, the ‘identifier’ code is available. This removes the need for a registration descriptor in the descriptor loop.
public enum SpliceDescriptor {
    case avail(info: AvailInfo)
    case dtmf(info: DTMFInfo)
    case segmentation(info: SegmentationInfo)
    case time(info: TimeInfo)
    case audio(info: AudioInfo)
    case unknown
}

protocol SpliceDescriptorInfo {
    var tag: Int { get }
    var length: Int { get }
    var identifier: Int { get }

    init?(tag: Int, length: Int, relevantBits: [Bit])
}
