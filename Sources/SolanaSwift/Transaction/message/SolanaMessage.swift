//
//  SolanaMessage.swift
//
//
//  Created by mathwallet on 2024/2/2.
//

import Foundation


public enum SolanaMessageVersion: String {
    case legacy = "legacy"
    case v0 = "0"
    
    public var byte: UInt8? {
        switch self {
        case .legacy:
            return nil
        default:
            return 1 << 7
        }
    }
}

public protocol SolanaMessage: BorshCodable,SolanaHumanReadable {
    var version: SolanaMessageVersion {get}
}

public struct SolanaMessageLegacy: SolanaMessage {
    public var version: SolanaMessageVersion { return .legacy }
    
    public var header: SolanaMessageHeader
    public var staticAccountKeys: [SolanaPublicKey]
    public var recentBlockhash: SolanaBlockHash
    public var compiledInstructions: [SolanaMessageCompiledInstruction]
    
    public func serialize(to writer: inout Data) throws {
        try self.header.serialize(to: &writer)
        try self.staticAccountKeys.serialize(to: &writer)
        try self.recentBlockhash.serialize(to: &writer)
        try self.compiledInstructions.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.header = try .init(from: &reader)
        self.staticAccountKeys = try .init(from: &reader)
        self.recentBlockhash = try .init(from: &reader)
        self.compiledInstructions = try .init(from: &reader)
    }
}

extension SolanaMessageLegacy {
    public func toHuman() -> Any {
        var instructions: [SolanaInstruction] = []
        for i in compiledInstructions {
            guard Int(i.programIdIndex) < self.compiledInstructions.count else { continue }
            let programId = self.staticAccountKeys[Int(i.programIdIndex)]
            let decodeInstruction = SolanaInstructionDecoder.decode(programId: programId, data: i.data, signers: [])
            instructions.append(decodeInstruction)
        }
        return [
            "instructions": instructions.map({$0.toHuman()}),
            "recentBlockhash": recentBlockhash.description
        ]
    }
}

public struct SolanaMessageV0: SolanaMessage {
    public var version: SolanaMessageVersion { return .v0 }
    
    public var header: SolanaMessageHeader
    public var staticAccountKeys: [SolanaPublicKey]
    public var recentBlockhash: SolanaBlockHash
    public var compiledInstructions: [SolanaMessageCompiledInstruction]
    public var addressTableLookups: [SolanaMessageAddressTableLookup]
    
    public func serialize(to writer: inout Data) throws {
        try self.header.serialize(to: &writer)
        try self.staticAccountKeys.serialize(to: &writer)
        try self.recentBlockhash.serialize(to: &writer)
        try self.compiledInstructions.serialize(to: &writer)
        try self.addressTableLookups.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        let versionByte = try UInt8.init(from: &reader)
        guard versionByte == SolanaMessageVersion.v0.byte else { throw BorshDecodingError.unknownData }
        
        self.header = try .init(from: &reader)
        self.staticAccountKeys = try .init(from: &reader)
        self.recentBlockhash = try .init(from: &reader)
        self.compiledInstructions = try .init(from: &reader)
        self.addressTableLookups = try .init(from: &reader)
    }
}

extension SolanaMessageV0 {
    public func toHuman() -> Any {
        var instructions: [SolanaInstruction] = []
        for i in compiledInstructions {
            guard Int(i.programIdIndex) < self.compiledInstructions.count else { continue }
            let programId = self.staticAccountKeys[Int(i.programIdIndex)]
            let decodeInstruction = SolanaInstructionDecoder.decode(programId: programId, data: i.data, signers: [])
            instructions.append(decodeInstruction)
        }
        return [
            "instructions": instructions.map({$0.toHuman()}),
            "recentBlockhash": recentBlockhash.description
        ]
    }
}
