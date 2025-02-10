//
//  SolanaMessage+Types.swift
//
//
//  Created by mathwallet on 2024/2/2.
//

import Foundation

public struct SolanaMessageHeader: BorshCodable {
    public var numRequiredSignatures: UInt8
    public var numReadonlySignedAccounts: UInt8
    public var numReadonlyUnsignedAccounts: UInt8
    
    public init(numRequiredSignatures: UInt8, numReadonlySignedAccounts: UInt8, numReadonlyUnsignedAccounts: UInt8) {
        self.numRequiredSignatures = numRequiredSignatures
        self.numReadonlySignedAccounts = numReadonlySignedAccounts
        self.numReadonlyUnsignedAccounts = numReadonlyUnsignedAccounts
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.numRequiredSignatures.serialize(to: &writer)
        try self.numReadonlySignedAccounts.serialize(to: &writer)
        try self.numReadonlyUnsignedAccounts.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.numRequiredSignatures = try .init(from: &reader)
        self.numReadonlySignedAccounts = try .init(from: &reader)
        self.numReadonlyUnsignedAccounts = try .init(from: &reader)
    }
}

public struct SolanaMessageAddressTableLookup: BorshCodable {
    public var accountKey: SolanaPublicKey
    public var writableIndexes: [UInt8]
    public var readonlyIndexes: [UInt8]
    
    public init(accountKey: SolanaPublicKey, writableIndexes: [UInt8], readonlyIndexes: [UInt8]) {
        self.accountKey = accountKey
        self.writableIndexes = writableIndexes
        self.readonlyIndexes = readonlyIndexes
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.accountKey.serialize(to: &writer)
        try self.writableIndexes.serialize(to: &writer)
        try self.readonlyIndexes.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.accountKey = try .init(from: &reader)
        self.writableIndexes = try .init(from: &reader)
        self.readonlyIndexes = try .init(from: &reader)
    }
}

public struct SolanaMessageCompiledInstruction: BorshCodable {
    public var programIdIndex: UInt8
    public var accountKeyIndexes: [UInt8]
    public var data: Data
    
    public init(programIdIndex: UInt8, accountKeyIndexes: [UInt8], data: Data) {
        self.programIdIndex = programIdIndex
        self.accountKeyIndexes = accountKeyIndexes
        self.data = data
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.programIdIndex.serialize(to: &writer)
        try self.accountKeyIndexes.serialize(to: &writer)
        try UVarInt(data.count).serialize(to: &writer)
        writer.append(data)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.programIdIndex = try .init(from: &reader)
        self.accountKeyIndexes = try .init(from: &reader)
        
        let dataCount = try UVarInt.init(from: &reader).value
        self.data = Data(try reader.read(count: dataCount))
    }
}

public struct SolanaMessageInstruction {
    public var programId: SolanaPublicKey
    public var accounts: [SolanaSigner]
    public var data: BorshCodable
    
    public init(programId: SolanaPublicKey, accounts: [SolanaSigner], data: BorshCodable) {
        self.programId = programId
        self.accounts = accounts
        self.data = data
    }
}
