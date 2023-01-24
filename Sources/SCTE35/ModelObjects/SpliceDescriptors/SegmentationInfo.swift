//
//  SegmentationInfo.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 6/5/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// The segmentation_descriptor() is an implementation of a splice_descriptor(). It provides an optional extension to the time_signal() and splice_insert() commands that allows for segmentation messages to be sent in a time/video accurate method. This descriptor shall only be used with the time_signal(), splice_insert() and the splice_null() commands. The time_signal() or splice_insert() message should be sent at least once a minimum of 4 seconds in advance of the signaled splice_time() to permit the insertion device to place the splice_info_section() accurately. Devices that do not recognize a value in any field shall ignore the message and take no action.
public struct SegmentationInfo: SpliceDescriptorInfo {
    /// This 8-bit number defines the syntax for the private bytes that make up the body of this descriptor. The splice_descriptor_tag shall have a value of 0x02.
    public let tag: Int

    /// This 8-bit number gives the length, in bytes, of the descriptor following this field.
    public let length: Int

    /// This 32-bit number is used to identify the owner of the descriptor. The identifier shall have a value of 0x43554549 (ASCII “CUEI”).
    public let identifier: Int

    /// A 32-bit unique segmentation event identifier. Only one occurrence of a given segmentation_event_id value shall be active at any one time. See discussion in Section Segmenting Content - Additional semantics10.3.3.5
    public let eventID: Int

    /// A 1-bit flag that, when set to ‘1’, indicates that a previously sent segmentation event, identified by segmentation_event_id, has been cancelled. The segmentation_type_id does not need to match between the original/cancelled segmentation event message and the message with the segmentation_event_cancel_indicator true. Once a segmentation event is cancelled, the segmentation_event_id may be reused for content identification or to start a new segment.
    public let eventCancelIndicator: Bool

    public let additionalInfo: SegmentationAdditionalInfo?

    init?(tag: Int, length: Int, relevantBits: [Bit]) {
        guard tag == 0x02 else { return nil }
        self.tag = tag
        guard length == (relevantBits.count / 8) else { return nil }
        self.length = length
        guard relevantBits.count >= 72 else { return nil }

        var bits = relevantBits
        let idRange = 0..<32
        let eventIDRange = 32..<64
        let eventCancelIndicatorLocation = 64

        self.identifier = BitConverter.integer(fromBits: Array(bits[idRange]))
        guard self.identifier == 0x43554549 else { return nil }
        self.eventID = BitConverter.integer(fromBits: Array(bits[eventIDRange]))
        self.eventCancelIndicator = bits[eventCancelIndicatorLocation] == .one

        bits.removeSubrange(0..<72)

        if self.eventCancelIndicator {
            self.additionalInfo = nil
        } else {
            guard let additionalInfo = SegmentationAdditionalInfo(relevantBits: bits) else { return nil }
            self.additionalInfo = additionalInfo
        }
    }
}

public struct SegmentationAdditionalInfo {
    /// A 1-bit flag that should be set to ‘1’ indicating that the message refers to a Program Segmentation Point and that the mode is the Program Segmentation Mode whereby all PIDs/components of the program are to be segmented. When set to ‘0’, this field indicates that the mode is the Component Segmentation Mode whereby each component that is intended to be segmented will be listed separately by the syntax that follows. The program_segmentation_flag can be set to different states during different descriptors messages within a program.
    public let isProgramSegmentedMode: Bool

    /// A 1-bit flag that should be set to ‘1’ indicating the presence of segmentation_duration field. The accuracy of the start time of this duration is constrained by the splice_command_type specified. For example, if a splice_null() command is specified, the precise position in the stream is not deterministic.
    public let hasSegmentationDuration: Bool

    /// When this bit has a value of ‘1’, the next five bits are reserved. When this bit has the value of ‘0’, the following additional information bits shall have the meanings defined below. This bit and the following five bits are provided to facilitate implementations that use methods that are out of scope of this standard to process and manage this segment.
    public let restrictions: Restrictions?

    /// An 8-bit unsigned integer that specifies the number of instances of elementary PID stream data in the loop that follows. Components are equivalent to elementary PID streams. If program_segmentation_flag == ‘0’ then the value of component_count shall be greater than or equal to 1.
    public let pidComponents: [PIDComponent]?

    /// A 40-bit unsigned integer that specifies the duration of the segment in terms of ticks of the program’s 90 kHz clock. It may be used to give the splicer an indication of when the segment will be over and when the next segmentation message will occur. Shall be 0 for end messages.
    public let segmentationDuration: Int?

    /// Length and identification from Table 21 - segmentation_upid_type. This structure’s contents and length are determined by the segmentation_upid_type and segmentation_upid_length fields. An example would be a type of 0x06 for ISAN and a length of 12 bytes. This field would then contain the ISAN identifier for the content to which this descriptor refers.
    public let segmentationUPID: SegmentationUPID

    /// The 8-bit value shall contain one of the values in Table 22 to designate type of segmentation. All unused values are reserved. When the segmentation_type_id is 0x01 (Content Identification), the value of segmentation_upid_type shall be non-zero. If segmentation_upid_length is zero, then segmentation_type_id shall be set to 0x00 for Not Indicated.
    public let segmentationTypeID: SegmentationTypeID

    /// This field provides support for numbering segments within a given collection of segments (such as chapters, advertisements or placement opportunities). This value, when utilized, is expected to reset to one at the beginning of a collection of segments. This field is expected to increment for each new segment (such as a chapter). The value of this field shall be as indicated in Table 22.
    public let segmentNumber: Int

    /// This field provides a count of the expected number of individual segments (such as chapters) within a collection of segments. The value of this field shall be as indicated in Table 22.
    public let segmentsExpected: Int

    /// If specified, this field provides identification for a specific sub-segment within a collection of sub-segments. This value, when utilized, is expected to be set to one for the first sub- segment within a collection of sub-segments. This field is expected to increment by one for each new sub- segment within a given collection. If present, descriptor_length shall include sub_segment_num in the byte count and serve as an indication to an implementation that sub_segment_num is present in the descriptor.

    /// The value of this field shall be as indicated in Table 22. Any other usage of sub_segment_num beyond that defined in Table 22 is out of scope of this standard.

    /// If sub_segment_num is provided, sub_segments_expected shall be provided.
    public let subSegmentNumber: Int?

    /// If specified, this field provides a count of the expected number of individual sub-segments within the collection of sub-segments. If present, descriptor_length shall include sub_segments_expected in the byte count and serve as an indication to an implementation that sub_segments_expected is present in the descriptor.
    public let subSegmentsExpected: Int?


    init?(relevantBits: [Bit]) {
        guard relevantBits.count >= 48 else { return nil }
        var bits = relevantBits
        let isProgramSegmentedLocation = 0
        self.isProgramSegmentedMode = bits[isProgramSegmentedLocation] == .one
        let hasSegmentationDurationLocation = 1
        self.hasSegmentationDuration = bits[hasSegmentationDurationLocation] == .one
        let hasNoRestrictionsLocation = 2

        if bits[hasNoRestrictionsLocation] == .one {
            restrictions = nil
        } else {
            let restrictionBitsRange = 3..<8
            let restrictionBits = Array(bits[restrictionBitsRange])
            if let restrictions = Restrictions(relevantBits: restrictionBits) {
                self.restrictions = restrictions
            } else {
                return nil
            }
        }
        bits.removeSubrange(0..<8)

        if isProgramSegmentedMode {
            self.pidComponents = nil
        } else {
            let componentCountRange = 0..<8
            let numberOfComponents = BitConverter.integer(fromBits: Array(bits[componentCountRange]))
            bits.removeSubrange(componentCountRange)

            var pidComponents = [PIDComponent]()
            for _ in 0..<numberOfComponents {
                guard bits.count >= 48 else { return nil }
                let nextComponentsBitRange = 0..<48
                let nextComponentsBits = Array(bits[nextComponentsBitRange])
                guard let component = PIDComponent(relevantBits: nextComponentsBits) else { return nil }
                pidComponents.append(component)
                bits.removeSubrange(nextComponentsBitRange)
            }
            self.pidComponents = pidComponents
        }

        if hasSegmentationDuration {
            guard bits.count >= 40 else { return nil }
            let segmentationDurationRange = 0..<40
            let segmentationDurationBits = Array(bits[segmentationDurationRange])
            self.segmentationDuration = BitConverter.integer(fromBits: segmentationDurationBits)
            bits.removeSubrange(segmentationDurationRange)
        } else {
            segmentationDuration = nil
        }

        let upidTypeRange = 0..<8
        let upidType = BitConverter.integer(fromBits: Array(bits[upidTypeRange]))
        let upidLengthRange = 8..<16
        let upidLengthInBytes = BitConverter.integer(fromBits: Array(bits[upidLengthRange]))


        let startIndex = 16
        let endIndex = 16 + (upidLengthInBytes * 8)
        guard bits.count > endIndex else { return nil }
        let segmentationBitsRange = startIndex..<endIndex
        let upidBits = Array(bits[segmentationBitsRange])
        guard let segmentationUPID = SegmentationUPID(type: upidType, length: upidLengthInBytes, relevantBits: upidBits) else {
            return nil
        }
        bits.removeSubrange(0..<endIndex)
        self.segmentationUPID = segmentationUPID

        guard bits.count >= 24 else { return nil }
        let segmentationTypeIDRange = 0..<8
        let tempSegmentationTypeID = BitConverter.integer(fromBits: Array(bits[segmentationTypeIDRange]))
        guard let segmentationTypeID = SegmentationTypeID(integerValue: tempSegmentationTypeID) else { return nil }
        self.segmentationTypeID = segmentationTypeID

        let segmentNumberRange = 8..<16
        self.segmentNumber = BitConverter.integer(fromBits: Array(bits[segmentNumberRange]))
        let segmentsExpectedRange = 16..<24
        self.segmentsExpected = BitConverter.integer(fromBits: Array(bits[segmentsExpectedRange]))

        if (tempSegmentationTypeID == 0x34 || tempSegmentationTypeID == 0x36) {
            bits.removeSubrange(0..<24)
            if bits.isEmpty {
                self.subSegmentNumber = 0
                self.subSegmentsExpected = 0
            } else if bits.count == 16 {
                let subSegmentNumberRange = 0..<8
                self.subSegmentNumber = BitConverter.integer(fromBits: Array(bits[subSegmentNumberRange]))
                let subSegmentsExpectedRange = 8..<16
                self.subSegmentsExpected = BitConverter.integer(fromBits: Array(bits[subSegmentsExpectedRange]))
            } else {
                return nil
            }
        } else {
            self.subSegmentNumber = nil
            self.subSegmentsExpected = nil
        }
    }
}

public struct Restrictions {
    /// This bit shall have the value of ‘1’ when there are no restrictions with respect to web delivery of this segment. This bit shall have the value of ‘0’ to signal that restrictions related to web delivery of this segment are asserted.
    public let isWebDeliveryAllowed: Bool

    /// This bit shall have the value of ‘1’ when there is no regional blackout of this segment. This bit shall have the value of ‘0’ when this segment is restricted due to regional blackout rules.
    public let isNotRegionallyBlackedOut: Bool

    /// This bit shall have the value of ‘1’ when there is no assertion about recording this segment. This bit shall have the value of 0 to signal that restrictions related to recording this segment are asserted.
    public let isArchiveAllowed: Bool

    /// See Table 20 for the meaning of this syntax element. This field signals three pre- defined groups of devices. The population of each group is independent and the groups are non- hierarchical. The delivery and format of the messaging to define the devices contained in the groups is out of the scope of this standard.
    public let deviceRestrictions: DeviceRestrictions

    init?(relevantBits: [Bit]) {
        guard relevantBits.count == 5 else { return nil }
        let isWebDeliveryAllowedLocation = 0
        self.isWebDeliveryAllowed = relevantBits[isWebDeliveryAllowedLocation] == .one
        let isNotRegionallyBlackedOutLocation = 1
        self.isNotRegionallyBlackedOut = relevantBits[isNotRegionallyBlackedOutLocation] == .one
        let isArchiveAllowedLocation = 2
        self.isArchiveAllowed = relevantBits[isArchiveAllowedLocation] == .one

        switch (relevantBits[3], relevantBits[4]) {
        case (.zero, .zero):
            self.deviceRestrictions = .restrictGroup0
        case (.zero, .one):
            self.deviceRestrictions = .restrictGroup1
        case (.one, .zero):
            self.deviceRestrictions = .restrictGroup2
        case (.one, .one):
            self.deviceRestrictions = .noRestrictions
        }
    }
}

/// See Table 20 for the meaning of this syntax element. This field signals three pre- defined groups of devices. The population of each group is independent and the groups are non- hierarchical. The delivery and format of the messaging to define the devices contained in the groups is out of the scope of this standard.
public enum DeviceRestrictions: CustomStringConvertible {
    case restrictGroup0
    case restrictGroup1
    case restrictGroup2
    case noRestrictions

    public var description: String {
        switch self {
        case .restrictGroup0, .restrictGroup1, .restrictGroup2:
            return "This segment is restricted for a class of devices defined by an out of band message that describes which devices are excluded."
        case .noRestrictions:
            return "This segment has no device restrictions."
        }
    }
}

public struct PIDComponent {
    /// An 8-bit value that identifies the elementary PID stream containing the Segmentation Point specified by the value of splice_time() that follows. The value shall be the same as the value used in the stream_identifier_descriptor() to identify that elementary PID stream. The presence of this field from the component loop denotes the presence of this component of the asset.
    public let componentTag: Int

    /// A 33-bit unsigned integer that shall be used by a splicing device as an offset to be added to the pts_time, as modified by pts_adjustment, in the time_signal() message to obtain the intended splice time(s). When this field has a zero value, then the pts_time field(s) shall be used without an offset. If splice_time() time_specified_flag = 0 or if the command this descriptor is carried with does not have a splice_time() field, this field shall be used to offset the derived immediate splice time.
    public let ptsOffset: Int

    init?(relevantBits: [Bit]) {
        guard relevantBits.count == 48 else { return nil }
        let componentTagRange = 0..<8
        let componentTagBits = Array(relevantBits[componentTagRange])
        self.componentTag = BitConverter.integer(fromBits: componentTagBits)

        let ptsOffsetRange = 15..<48
        let ptsOffsetBits = Array(relevantBits[ptsOffsetRange])
        self.ptsOffset = BitConverter.integer(fromBits: ptsOffsetBits)
    }
}

/// Segmentation_upid according to segmentation_upid_type as defined in Table 21.
public struct SegmentationUPID: Equatable {
    /// A value from the following table. There are multiple types allowed to ensure that programmers will be able to use an id that their systems support. It is expected that the consumers of these ids will have an out-of-band method of collecting other data related to these numbers and therefore they do not need to be of identical types. These ids may be in other descriptors in the program and, where the same identifier is used (ISAN for example), it shall match between programs.
    public let type: UInt8

    /// Length in bytes of segmentation_upid() as indicated by Table 21. If there is no segmentation_upid() present, segmentation_upid_length shall be set to zero.
    private let length: UInt8

    /// Length and identification from Table 21 - segmentation_upid_type. This structure’s contents and length are determined by the segmentation_upid_type and segmentation_upid_length fields. An example would be a type of 0x06 for ISAN and a length of 12 bytes. This field would then contain the ISAN identifier for the content to which this descriptor refers.
    public var name: String {
        switch type {
        case 0x00:
            return "Not Used"
        case 0x01:
            return "User Defined"
        case 0x02:
            return "ISCI"
        case 0x03:
            return "Ad-ID"
        case 0x04:
            return "UMID"
        case 0x05:
            return "ISAN"
        case 0x06:
            return "V-ISAN"
        case 0x07:
            return "TID"
        case 0x08:
            return "TI"
        case 0x09:
            return "ADI"
        case 0x0A:
            return "EIDR"
        case 0x0B:
            return "ATSC Content Identifier"
        case 0x0C:
            return "MPU()"
        case 0x0D:
            return "MID()"
        case 0x0E:
            return "ADS Information"
        case 0x0F:
            return "URI"
        case 0x10:
            return "UUID"
        case 0x11...0xFF:
            return "reserved"
        default:
            return "Undefined UPID type"
        }
    }

    public var description: String {
        switch type {
        case 0x00:
            return "The segmentation_upid is not defined and is not present in the descriptor."
        case 0x01:
            return "Deprecated: use type 0x0C; The segmentation_upid does not follow a standard naming scheme."
        case 0x02:
            return "Deprecated: use type 0x03, 8 characters; 4 alpha characters followed by 4 numbers."
        case 0x03:
            return "Defined by the Advertising Digital Identification, LLC group. 12 characters; 4 alpha characters (company identification prefix) followed by 8 alphanumeric characters. (See [Ad-ID])"
        case 0x04:
            return "See [SMPTE 330]"
        case 0x05:
            return "Deprecated: use type 0x06, ISO 15706 binary encoding."
        case 0x06:
            return "Formerly known as V-ISAN. ISO 15706-2 binary encoding (“versioned” ISAN). See [ISO 15706-2]."
        case 0x07:
            return "Tribune Media Systems Program identifier. 12 characters; 2 alpha characters followed by 10 numbers."
        case 0x08:
            return "AiringID (Formerly Turner ID), used to indicate a specific airing of a program that is unique within a network."
        case 0x09:
            return "CableLabs metadata identifier as defined in Section 10.3.3.2."
        case 0x0A:
            return "An EIDR (see [EIDR]) represented in Compact Binary encoding as defined in Section 2.1.1 in EIDR ID Format (see [EIDR ID FORMAT])"
        case 0x0B:
            return "ATSC_content_identifier() structure as defined in [ATSC A/57B]."
        case 0x0C:
            return "Managed Private UPID structure as defined in section 10.3.3.3."
        case 0x0D:
            return "Multiple UPID types structure as defined in section 10.3.3.4."
        case 0x0E:
            return "Advertising information. The specific usage is out of scope of this standard."
        case 0x0F:
            return "Universal Resource Identifier (see [RFC 3986])."
        case 0x10:
            return "Universally unique identifier (see [RFC 4122])."
        case 0x11...0xFF:
            return "Reserved for future standardization."
        default:
            return "UPID type is not currently defined."
        }
    }

    public var info: SegmentationUPIDInformation?

    init?(type: Int, length: Int, relevantBits: [Bit]) {
        guard type <= 0x10 else { return nil }
        self.type = UInt8(type)
        self.length = UInt8(length)

        if relevantBits.isEmpty {
            self.info = nil
        } else {
            self.info = SegmentationUPIDInformation(type: type, relevantBits: relevantBits)
        }
    }

    static func getMultipleUpids(from relevantBits: [Bit]) -> [SegmentationUPID]? {
        guard relevantBits.count >= 16 else { return nil }

        var upids = [SegmentationUPID]()

        var bits = relevantBits
        while bits.count > 0 {
            let upidTypeRange = 0..<8
            let upidType = BitConverter.integer(fromBits: Array<Bit>(bits[upidTypeRange]))
            let upidLengthRange = 8..<16
            let upidLengthInBytes = BitConverter.integer(fromBits: Array<Bit>(bits[upidLengthRange]))
            let startIndex = 16
            let endIndex = 16 + (upidLengthInBytes * 8)
            guard bits.count >= endIndex else { return nil }
            let segmentationBitsRange = startIndex..<endIndex
            let upidBits = Array<Bit>(bits[segmentationBitsRange])
            guard let segmentationUPID = SegmentationUPID(type: upidType, length: upidLengthInBytes, relevantBits: upidBits) else {
                return nil
            }
            upids.append(segmentationUPID)
            bits.removeSubrange(0..<endIndex)
        }

        return upids
    }
}

extension SegmentationUPID: BitEncodable {
    func encode() throws -> [Bit] {
        var bits = [Bit]()
        bits.append(contentsOf: BitConverter.bits(from: type))
        bits.append(contentsOf: BitConverter.bits(from: length))

        switch info {
        case .none:
            break
        case .userDefined(let value):
            let userDefinedBits = BitConverter.bits(fromData: value)
            bits.append(contentsOf: userDefinedBits)

        case .ISCI(let value), .AdID(let value), .UMID(let value), .VISAN(let value),
                .ISAN(let value), .TID(let value), .TI(let value), .ADI(let value),
                .EIDR(let value), .MPU(let value), .ADS(let value), .URI(let value), .UUID(let value):
            guard let stringData = value.data(using: .utf8) else { throw SCTE35ParsingError.invalidStringAsUtf8 }
            let stringBits = BitConverter.bits(fromData: stringData)
            bits.append(contentsOf: stringBits)

        case .ATSC(let atsc):
            let atscBits = try atsc.encode()
            bits.append(contentsOf: atscBits)

        case .MID(let upids):
            let midBits = try encodeMultipleUpids(upids)
            bits.append(contentsOf: midBits)

        }

        return bits
    }

    private func encodeMultipleUpids(_ upids: [SegmentationUPID]) throws -> [Bit] {
        var allUpidBits = [Bit]()
        for upid in upids {
            let multiUpidBits = try upid.encode()
            allUpidBits.append(contentsOf: multiUpidBits)
        }
        return allUpidBits
    }
}

public enum SegmentationUPIDInformation: Equatable {
    case userDefined(Data)
    case ISCI(String)
    case AdID(String)
    case UMID(String)
    case ISAN(String)
    case VISAN(String)
    case TID(String)
    case TI(String)
    case ADI(String)
    case EIDR(String)
    case ATSC(ATSCContentIdentifier)
    case MPU(String)
    case MID([SegmentationUPID])
    case ADS(String)
    case URI(String)
    case UUID(String)

    init?(type: Int, relevantBits: [Bit]) {
        switch type {
        case 0x01:
            self = .userDefined(BitConverter.data(from: relevantBits))

        case 0x02:
            guard
                relevantBits.count == 64,
                let string = BitConverter.string(fromBits: relevantBits)
            else { return nil }
            self = .ISCI(string)

        case 0x03:
            guard
                relevantBits.count == 96,
                let adId = BitConverter.adIdString(from: relevantBits)
            else { return nil }
            self = .AdID(adId)

        case 0x04:
            guard
                relevantBits.count == 256,
                let smtpe = BitConverter.umidString(fromBits: relevantBits)
            else { return nil }
            self = .UMID(smtpe)

        case 0x05:
            guard
                relevantBits.count == 64,
                let isan = BitConverter.isanString(fromBits: relevantBits)
            else { return nil }
            self = .ISAN(isan)

        case 0x06:
            guard
                relevantBits.count == 96,
                let isan = BitConverter.isanString(fromBits: relevantBits)
            else { return nil }
            self = .VISAN(isan)

        case 0x07:
            guard
                relevantBits.count == 96,
                let tid = BitConverter.tidString(from: relevantBits)
            else { return nil }
            self = .TID(tid)

        case 0x08:
            guard
                relevantBits.count == 64,
                let ti = BitConverter.hexString(fromBits: relevantBits)
            else { return nil }
            self = .TI(ti)

        case 0x09:
            guard let adi = BitConverter.adiString(from: relevantBits) else { return nil }
            self = .ADI(adi)

        case 0x0A:
            guard
                relevantBits.count == 96,
                let eidr = BitConverter.eidrString(fromBits: relevantBits)
            else { return nil }
            self = .EIDR(eidr)

        case 0x0B:
            guard let atsc = ATSCContentIdentifier(from: relevantBits) else { return nil }
            self = .ATSC(atsc)

        case 0x0C:
            guard let mpu = BitConverter.string(fromBits: relevantBits) else { return nil }
            self = .MPU(mpu)

        case 0x0D:
            guard
                let multiUpids = SegmentationUPID.getMultipleUpids(from: relevantBits),
                multiUpids.count > 0
            else { return nil }
            self = .MID(multiUpids)

        case 0x0E:
            guard let ads = BitConverter.string(fromBits: relevantBits) else { return nil }
            self = .ADS(ads)

        case 0x0F:
            guard let uri = BitConverter.string(fromBits: relevantBits) else { return nil }
            self = .URI(uri)

        case 0x10:
            guard
                relevantBits.count == 128,
                let uuid = BitConverter.hexString(fromBits: relevantBits) else { return nil }
            self = .UUID(uuid)

        default:
            return nil
        }
    }
}

public enum SegmentationTypeID {
    case notIndicated
    case contentIdentification
    case programStart
    case programEnd
    case programEarlyTermination
    case programBreakaway
    case programResumption
    case programRunoverPlanned
    case programRunoverUnplanned
    case programOverlapStart
    case programBlackoutOverride
    case programStartInProgress
    case chapterStart
    case chapterEnd
    case breakStart
    case breakEnd
    case openingCreditStart
    case openingCreditEnd
    case closingCreditStart
    case closingCreditEnd
    case providerAdvertisementStart
    case providerAdvertisementEnd
    case distributorAdvertisementStart
    case distributorAdvertisementEnd
    case providerPlacementOpportunityStart
    case providerPlacementOpportunityEnd
    case distributorPlacementOpportunityStart
    case distributorPlacementOpportunityEnd
    case providerOverlayPlacementOpportunityStart
    case providerOverlayPlacementOpportunityEnd
    case distributorOverlayPlacementOpportunityStart
    case distributorOverlayPlacementOpportunityEnd
    case unscheduledEventStart
    case unscheduledEventEnd
    case networkStart
    case networkEnd

    public init?(integerValue: Int) {
        switch integerValue {
        case 0x00:
            self = .notIndicated
        case 0x01:
            self = .contentIdentification
        case 0x10:
            self = .programStart
        case 0x11:
            self = .programEnd
        case 0x12:
            self = .programEarlyTermination
        case 0x13:
            self = .programBreakaway
        case 0x14:
            self = .programResumption
        case 0x15:
            self = .programRunoverPlanned
        case 0x16:
            self = .programRunoverUnplanned
        case 0x17:
            self = .programOverlapStart
        case 0x18:
            self = .programBlackoutOverride
        case 0x19:
            self = .programStartInProgress
        case 0x20:
            self = .chapterStart
        case 0x21:
            self = .chapterEnd
        case 0x22:
            self = .breakStart
        case 0x23:
            self = .breakEnd
        case 0x24:
            self = .openingCreditStart
        case 0x25:
            self = .openingCreditEnd
        case 0x26:
            self = .closingCreditStart
        case 0x27:
            self = .closingCreditEnd
        case 0x30:
            self = .providerAdvertisementStart
        case 0x31:
            self = .providerAdvertisementEnd
        case 0x32:
            self = .distributorAdvertisementStart
        case 0x33:
            self = .distributorAdvertisementEnd
        case 0x34:
            self = .providerPlacementOpportunityStart
        case 0x35:
            self = .providerPlacementOpportunityEnd
        case 0x36:
            self = .distributorPlacementOpportunityStart
        case 0x37:
            self = .distributorPlacementOpportunityEnd
        case 0x38:
            self = .providerOverlayPlacementOpportunityStart
        case 0x39:
            self = .providerOverlayPlacementOpportunityEnd
        case 0x3A:
            self = .distributorOverlayPlacementOpportunityStart
        case 0x3B:
            self = .distributorOverlayPlacementOpportunityEnd
        case 0x40:
            self = .unscheduledEventStart
        case 0x41:
            self = .unscheduledEventEnd
        case 0x50:
            self = .networkStart
        case 0x51:
            self = .networkEnd
        default:
            return nil
        }
    }
    
    public init?(stringValue: String) {
        switch stringValue {
        case "0x00":
            self = .notIndicated
        case "0x01":
            self = .contentIdentification
        case "0x10":
            self = .programStart
        case "0x11":
            self = .programEnd
        case "0x12":
            self = .programEarlyTermination
        case "0x13":
            self = .programBreakaway
        case "0x14":
            self = .programResumption
        case "0x15":
            self = .programRunoverPlanned
        case "0x16":
            self = .programRunoverUnplanned
        case "0x17":
            self = .programOverlapStart
        case "0x18":
            self = .programBlackoutOverride
        case "0x19":
            self = .programStartInProgress
        case "0x20":
            self = .chapterStart
        case "0x21":
            self = .chapterEnd
        case "0x22":
            self = .breakStart
        case "0x23":
            self = .breakEnd
        case "0x24":
            self = .openingCreditStart
        case "0x25":
            self = .openingCreditEnd
        case "0x26":
            self = .closingCreditStart
        case "0x27":
            self = .closingCreditEnd
        case "0x30":
            self = .providerAdvertisementStart
        case "0x31":
            self = .providerAdvertisementEnd
        case "0x32":
            self = .distributorAdvertisementStart
        case "0x33":
            self = .distributorAdvertisementEnd
        case "0x34":
            self = .providerPlacementOpportunityStart
        case "0x35":
            self = .providerPlacementOpportunityEnd
        case "0x36":
            self = .distributorPlacementOpportunityStart
        case "0x37":
            self = .distributorPlacementOpportunityEnd
        case "0x38":
            self = .providerOverlayPlacementOpportunityStart
        case "0x39":
            self = .providerOverlayPlacementOpportunityEnd
        case "0x3A":
            self = .distributorOverlayPlacementOpportunityStart
        case "0x3B":
            self = .distributorOverlayPlacementOpportunityEnd
        case "0x40":
            self = .unscheduledEventStart
        case "0x41":
            self = .unscheduledEventEnd
        case "0x50":
            self = .networkStart
        case "0x51":
            self = .networkEnd
        default:
            return nil
        }
    }
}
