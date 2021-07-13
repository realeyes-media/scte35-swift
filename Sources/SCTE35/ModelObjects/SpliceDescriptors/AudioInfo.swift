//
//  AudioInfo.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 6/5/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// The audio_descriptor() should be used when programmers and/or MVPDs do not support dynamic signaling (e.g., signaling of audio language changes) and with legacy audio formats that do not support dynamic signaling. As discussed in Section 9.1.5 of the SCTE Operational Practice on Multiple Audio Signaling [SCTE 248], since most MVPD headends do not change the PAT/PMT to signal changed audio streams, this descriptor in SCTE 35 should be used to signal such changes. This descriptor is an implementation of a splice_descriptor(). It provides the ability to dynamically signal the audios actually in use in the stream. This descriptor shall only be used with a time_signal command and a segmentation descriptor with the type Program_Start or Program_Overlap_Start.
public struct AudioInfo: SpliceDescriptorInfo {
    /// This 8-bit number defines the syntax for the private bytes that make up the body of this descriptor. The splice_descriptor_tag shall have a value of 0x04.
    public let tag: Int

    /// This 8-bit number gives the length, in bytes, of the descriptor following this field.
    public let length: Int

    /// This 32-bit number is used to identify the owner of the descriptor. The identifier shall have a value of 0x43554549 (ASCII “CUEI”).
    public let identifier: Int

    /// The value of this flag is the number of audio PIDs in the program.
    public let audioCount: Int

    public let audioPIDs: [AudioPid]

    init?(tag: Int, length: Int, relevantBits: [Bit]) {
        guard tag == 0x04 else { return nil }
        self.tag = tag
        self.length = length
        var bits = relevantBits
        guard bits.count >= 38 else { return nil }

        let identifierRange = 0..<32
        self.identifier = BitConverter.integer(fromBits: Array(relevantBits[identifierRange]))
        let audioCountRange = 32..<36
        self.audioCount = BitConverter.integer(fromBits: Array(relevantBits[audioCountRange]))
        bits.removeSubrange(0..<40)

        var audioPIDs = [AudioPid]()
        for _ in 0..<audioCount {
            guard bits.count >= 40 else { return nil }
            let nextAudioPIDRange = 0..<40
            let nextAudioPIDBits = Array(bits[nextAudioPIDRange])
            guard let nextAudioPID = AudioPid(relevantBits: nextAudioPIDBits) else { return nil }
            audioPIDs.append(nextAudioPID)
            bits.removeSubrange(nextAudioPIDRange)
        }
        self.audioPIDs = audioPIDs
    }
}

public struct AudioPid {
    /// An optional 8-bit value that identifies the elementary PID stream containing the audio channel that follows. If used, the value shall be the same as the value used in the stream_identifier_descriptor() to identify that elementary PID stream. If this is not used, the value shall be 0xFF and the stream order shall be inferred from the PMT audio order.
    public let componentTag: Int

    /// This field is a 3-byte language code defining the language of this audio service which shall correspond to a registered language code contained in the Code column of the [ISO 639-2] registry.
    public let isoCode: Int

    /// As per ATSC A/52 Table 5.7.
    public let bitStreamMode: Int

    /// As per ATSC A/52 Table A4.5.
    public let numberOfChannels: Int

    /// “This is a 1-bit field that indicates if this audio service is a full service suitable for presentation, or a partial service which should be combined with another audio service before presentation. This bit should be set to a ‘1’ if this audio service is sufficiently complete to be presented to the listener without being combined with another audio service (for example, a visually impaired service which contains all elements of the program; music, effects, dialogue, and the visual content descriptive narrative). This bit should be set to a ‘0’ if the service is not sufficiently complete to be presented without being combined with another audio service (e.g., a visually impaired service which only contains a narrative description of the visual program content and which needs to be combined with another audio service which contains music, effects, and dialogue).”
    public let isFullServiceAudio: Bool

    init?(relevantBits: [Bit]) {
        guard relevantBits.count == 40 else { return nil }
        let componentTagRange = 0..<8
        self.componentTag = BitConverter.integer(fromBits: Array(relevantBits[componentTagRange]))
        let isoCodeRange = 8..<32
        self.isoCode = BitConverter.integer(fromBits: Array(relevantBits[isoCodeRange]))
        let bitStreamModeRange = 32..<35
        self.bitStreamMode = BitConverter.integer(fromBits: Array(relevantBits[bitStreamModeRange]))
        let numberOfChannelsRange = 35..<39
        self.numberOfChannels = BitConverter.integer(fromBits: Array(relevantBits[numberOfChannelsRange]))
        let isFullServiceAudioLocation = 39
        self.isFullServiceAudio = relevantBits[isFullServiceAudioLocation] == .one
    }
}
