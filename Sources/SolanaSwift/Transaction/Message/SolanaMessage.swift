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
    
    public init(_ instructions: [SolanaMessageInstruction], blockhash: SolanaBlockHash = .EMPTY, feePayer: SolanaPublicKey? = nil) throws {
        // StaticAccountKeys
        var tempSigners = [SolanaSigner]()
        tempSigners.append(contentsOf: instructions.flatMap({ $0.accounts }))
        tempSigners.append(contentsOf: instructions.map({ SolanaSigner(publicKey: $0.programId) }))
        // Deduplication
        var signers = [SolanaSigner]()
        for s in tempSigners {
            if let i = signers.firstIndex(of: s){
                signers[i].isSigner = signers[i].isSigner || s.isSigner
                signers[i].isWritable = signers[i].isWritable || s.isWritable
            } else {
                signers.append(s)
            }
        }
        // Sorted
        signers = signers.sorted(by: <)
        // Move fee payer to the front
        if let payer = feePayer, let i = signers.map({ $0.publicKey }).firstIndex(of: payer), i > 0 {
            signers.remove(at: i)
            signers.insert(SolanaSigner(publicKey: payer, isSigner: true, isWritable: true), at: 0)
        }
        let publicKeys = signers.map({$0.publicKey})
        
        // Header
        self.header = SolanaMessageHeader(
            numRequiredSignatures: UInt8(signers.filter({ $0.isSigner }).count),
            numReadonlySignedAccounts: UInt8(signers.filter({ $0.isSigner && !$0.isWritable }).count),
            numReadonlyUnsignedAccounts: UInt8(signers.filter({ !$0.isSigner && !$0.isWritable }).count)
        )
        // Accounts
        self.staticAccountKeys = signers.map({$0.publicKey})
        // Recent Blockhash
        self.recentBlockhash = blockhash
        // Compiled Instruction
        self.compiledInstructions = []
        for instruction in instructions {
            let programIdIndex = UInt8(publicKeys.firstIndex(of: instruction.programId)!)
            let accountKeyIndexes = instruction.accounts.map({ UInt8(publicKeys.firstIndex(of: $0.publicKey)!) })
            let data = try BorshEncoder().encode(instruction.data)
            
            let compiledInstruction = SolanaMessageCompiledInstruction(
                programIdIndex: programIdIndex,
                accountKeyIndexes: accountKeyIndexes,
                data: data
            )
            self.compiledInstructions.append(compiledInstruction)
        }
    }
}

extension SolanaMessageLegacy {
    public func toHuman() -> Any {
        var instructions: [SolanaInstruction] = []
        for i in compiledInstructions {
            guard Int(i.programIdIndex) < self.staticAccountKeys.count else { continue }
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
        try self.version.byte!.serialize(to: &writer)
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
            guard Int(i.programIdIndex) < self.staticAccountKeys.count else { continue }
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
