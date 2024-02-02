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
        self.data = Data(reader.read(count: dataCount))
    }
}
