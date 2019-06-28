//
//  SpliceCommand.swift
//  SCTE35Converter
//
//  Created by Joe Lucero on 5/30/19.
//  Copyright © 2019 Real Eyes Media. All rights reserved.
//

import Foundation

/// One of 6 different commands (and 1 group of reserved values) that indicate defined commands. Inside of the public commands, there will be an associated value with additional information.
public enum SpliceCommand {
    /// The splice_null() command is provided for extensibility of the standard. The splice_null() command allows a splice_info_table to be sent that can carry descriptors without having to send one of the other defined commands. This command may also be used as a “heartbeat message” for monitoring cue injection equipment integrity and link integrity.
    case null

    /// The term “reserved”, when used in the clauses defining the coded bit stream, indicates that the value may be used in the future for extensions to the standard. Unless otherwise specified, all reserved bits shall be set to ‘1’ and this field shall be ignored by receiving equipment.
    case reserved

    /// The splice_schedule() command is provided to allow a schedule of splice events to be conveyed in advance.
    case schedule(scheduleInfo: ScheduleInfo)
    
    /// The splice_insert() command shall be sent at least once for every splice event. Please reference section 6.3 for the use of this message.
    case insert(insertEvent: InsertEvent)

    /// The time_signal() provides a time synchronized data delivery mechanism. The syntax of the time_signal() allows for the synchronization of the information carried in this message with the System Time Clock (STC). The unique payload of the message is carried in the descriptor, however the syntax and transport capabilities afforded to splice_insert() messages are also afforded to the time_signal(). The carriage however can be in a different PID than that carrying the other cue messages used for signaling splice points.

    /// If the time_specified_flag is set to 0, indicating no pts_time in the message, then the command shall be interpreted as an immediate command. It must be understood that using it in this manner will cause an unspecified amount of accuracy error.
    case timeSignal(spliceTime: SpliceTime)

    /// The bandwidth_reservation() command is provided for reserving bandwidth in a multiplex. A typical usage would be in a satellite delivery system that requires packets of a certain PID to always be present at the intended repetition rate to guarantee a certain bandwidth for that PID. This message differs from a splice_null() command so that it can easily be handled in a unique way by receiving equipment (i.e. removed from the multiplex by a satellite receiver). If a descriptor is sent with this command, it can not be expected that it will be carried through the entire transmission chain and it should be a private descriptor that is utilized only by the bandwidth reservation process.
    case bandwidthReservation

    /// The private_command() structure provides a means to distribute user-defined commands using the SCTE 35 protocol. The first bit field in each user-defined command is a 32-bit identifier, unique for each participating vendor. Receiving equipment should skip any splice_info_section() messages containing private_command() structures with unknown identifiers.
    case privateCommand

    /// - Throws: An error of type `SCTE35ParsingError`
    internal init(spliceCommandType: Int, relevantBits: [Bit]) throws {
        guard spliceCommandType >= 0 && spliceCommandType <= 0xff else {
            throw SCTE35ParsingError.invalidSpliceCommandType
        }
        switch spliceCommandType {
        case 0:
            self = .null
        case 4:
            guard let scheduleInfo = ScheduleInfo(bits: relevantBits) else {
                throw SCTE35ParsingError.unableToCreateSpliceCommand(type: CommandType.schedule)
            }
            self = .schedule(scheduleInfo: scheduleInfo)
        case 5:
            do {
                let insertEvent = try InsertEvent(bits: relevantBits)
                self = .insert(insertEvent: insertEvent)
            } catch {
                throw error
            }
        case 6:
            var bits = relevantBits
            guard let spliceTime = SpliceTime(bits: &bits) else {
                throw SCTE35ParsingError.unableToCreateSpliceCommand(type: CommandType.timeSignal)
            }
            self = .timeSignal(spliceTime: spliceTime)
        case 7:
            self = .bandwidthReservation
        case 0xff:
            self = .privateCommand
        default:
            self = .reserved
        }
    }
}
