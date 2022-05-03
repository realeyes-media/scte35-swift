//
//  SpliceInfoSection.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/29/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/**
 SpliceInfoSection is the Swifty version of SCTE-35 Standards as defined in the documents linked below. Use SCTE35Converter
 to parse a Base64String and create a SpliceInfoSection

 [SCTE35 Standards]: https://www.scte.org/SCTEDocs/Standards/SCTE%2035%202019r1.pdf

 For Reference on Terminology and definitions see [SCTE35 Standards].
 Definitions of properties are copied and pasted from here
 See Page 12 for definitions and abbreviations
 */
public struct SpliceInfoSection {
    /// This is an 8-bit field. Its value shall be 0xFC.
    public let tableID: Int

    /// The section_syntax_indicator is a 1-bit field that should always be set to false, indicating that MPEG short sections
    /// are to be used.
    public let isSectionSyntaxIndicatorOn: Bool

    /// This is a 1-bit flag that shall be set to 0.
    public let isPrivateIndicatorOn: Bool

    /**
     This is a 12-bit field specifying the number of remaining bytes in the splice_info_section, immediately following the
     section_length field up to the end of the splice_info_section. The value in this field shall not exceed 4093.
     */
    public let sectionLength: Int

    /**
     An 8-bit unsigned integer field whose function is to allow, in the future, this table type to carry parameters that
     may be structured differently than those defined in the current protocol. At present, the only valid value for protocol_version
     is zero. Non-zero values of protocol_version may be used by a future version of this standard to indicate structurally different tables.
     */
    public let protocolVersion: Int

    /**
     When this bit is set to ‘1’, it indicates that portions of the splice_info_section, starting with splice_command_type
     and ending with and including E_CRC_32, are encrypted. When this bit is set to ‘0’, no part of this message is encrypted.
     The potentially encrypted portions of the splice_info_table are indicated by an E in the Encrypted column of Table 5.
     */
    public let hasEncryptedPacket: Bool

    /**
     This 6-bit unsigned integer specifies which encryption algorithm was used to encrypt the current message. When the
     encrypted_packet bit is zero, this field is present but undefined. Refer to section 11, and specifically Table 27 - Encryption
     algorithm, for details on the use of this field.
     */
    public let encryptionAlgorithm: EncryptionAlgorithm

    /**
     A 33-bit unsigned integer that appears in the clear and that shall be used by a splicing device as an offset to be
     added to the (sometimes) encrypted pts_time field(s) throughout this message, to obtain the intended splice time(s).
     When this field has a zero value, then the pts_time field(s) shall be used without an offset. Normally, the creator
     of a cueing message will place a zero value into this field.

     This adjustment value is the means by which an upstream device, which restamps pcr/pts/dts, may convey to the
     splicing device the means by which to convert the pts_time field of the message to a newly imposed time domain.

     It is intended that the first device that restamps pcr/pts/dts and that passes the cueing message will insert a
     value into the pts_adjustment field, which is the delta time between this device’s input time domain and its output
     time domain. All subsequent devices, which also restamp pcr/pts/dts, may further alter the pts_adjustment field by
     adding their delta time to the field’s existing delta time and placing the result back in the pts_adjustment field.
     Upon each alteration of the pts_adjustment field, the altering device shall recalculate and update the CRC_32 field.

     The pts_adjustment shall, at all times, be the proper value to use for conversion of the pts_time field to the current
     time-base. The conversion is done by adding the two fields. In the presence of a wrap or overflow condition,
     the carry shall be ignored.
     */
    public let ptsAdjustment: Int

    /**
     An 8-bit unsigned integer that conveys which control word (key) is to be used to decrypt the message. The splicing
     device may store up to 256 keys previously provided for this purpose. When the encrypted_packet bit is zero, this
     field is present but undefined.
     */
    public let cwIndex: Int

    /**
     A 12-bit value used by the SCTE 35 message provider to assign messages to authorization tiers. This field may take
     any value between 0x000 and 0xFFF. The value of 0xFFF provides backwards compatibility and shall be ignored by downstream
     equipment. When using tier, the message provider should keep the entire message in a single transport stream packet.
     */
    public let tier: Tier

    /**
     A 12-bit length of the splice command. The length shall represent the number of bytes following the splice_command_type
     up to, but not including the descriptor_loop_length. Devices that are compliant with this version of the standard shall
     populate this field with the actual length. The value of 0xFFF provides backwards compatibility and shall be ignored
     by downstream equipment.
     */
    public let spliceCommandLength: Int

    /// An 8-bit unsigned integer which shall be assigned one of the values shown in column labeled splice_command_type value
    /// in Table 6.
    public let spliceCommandType: Int

    /// One of 6 different commands (and 1 group of reserved values) that indicate defined commands. Inside of the public
    /// commands, there will be an associated value with additional information.
    public let spliceCommand: SpliceCommand

    /// A 16-bit unsigned integer specifying the number of bytes used in the splice descriptor loop immediately following.
    public let descriptorLoopLength: Int

    /**
     The splice_descriptor is a prototype for adding new fields to the splice_info_section. All descriptors included use the
     same syntax for the first six bytes. In order to allow private information to be added, the ‘identifier’ code is available.
     This removes the need for a registration descriptor in the descriptor loop.

     Any receiving equipment should skip any descriptors with unknown identifiers or unknown descriptor tags. For descriptors
     with known identifiers, the receiving equipment should skip descriptors with an unknown splice_descriptor_tag.

     Splice descriptors may exist in the splice_info_section for extensions specific to the various commands.

     Table 15 lists the defined Splice Descriptor Tags. Both the tag values that shall be used for Bit Stream Format as well
     as the XML Element that shall be used to identify each specific Splice Descriptor are listed.

     Implementers note: Multiple descriptors of the same or different types in a single command are allowed and may be common.
     One case of multiple segmentation_descriptors is described in Section 10.3.3.2. The only limit on the number of descriptors
     is the section_length in Table 5, although there may be other practical or implementation limits.
     */
    public let spliceDescriptors: [SpliceDescriptor]

    /**
     This is a 32-bit field that contains the CRC value that gives a zero output of the registers in the decoder defined
     in [MPEG Systems]after processing the entire splice_info_section, which includes the table_id field through the
     CRC_32 field. The processing of CRC_32 shall occur prior to decryption of the encrypted fields and shall utilize the
     encrypted fields in their encrypted state.
     */
    public let crc32: String

    /**
     This is a 32-bit field that contains the CRC value that gives a zero output of the registers in the decoder defined
     in [MPEG Systems]after processing the entire decrypted portion of the splice_info_section. This field is intended to
     give an indication that the decryption was performed successfully. Hence, the zero output is obtained following decryption
     and by processing the fields splice_command_type through E_CRC_32.
     */
    public let ecrc32: String?
}
