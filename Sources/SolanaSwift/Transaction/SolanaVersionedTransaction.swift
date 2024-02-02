//
//  SolanaVersionedTransaction.swift
//
//
//  Created by mathwallet on 2024/2/1.
//

import Foundation

public struct SolanaVersionedTransaction {
    public var version: SolanaMessageVersion {
        return message.version
    }
    public var message: SolanaMessage
}

extension SolanaVersionedTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try message.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        let ver: SolanaMessageVersion
        guard let prefix: UInt8 = reader.bytes.first else { throw BorshDecodingError.unknownData }
        let maskedPrefix: UInt8 = (prefix & 0x7f)
        if maskedPrefix != prefix && maskedPrefix == 0 {
            ver = .v0
        } else {
            ver = .legacy
        }
        switch ver {
        case .legacy:
            message = try SolanaMessageLegacy.init(from: &reader)
        case .v0:
            message = try SolanaMessageV0.init(from: &reader)
        }
    }
}

extension SolanaVersionedTransaction: SolanaHumanReadable {
    
    public func toHuman() -> Any {
        return message.toHuman()
    }
    
}

public struct SolanaSignedVersionedTransaction {
    public let transaction: SolanaVersionedTransaction
    public let signatures: [SolanaSignature]
    
    public init(transaction: SolanaVersionedTransaction, signatures: [SolanaSignature]) {
        self.transaction = transaction
        self.signatures = signatures
    }
}

extension SolanaSignedVersionedTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try signatures.serialize(to: &writer)
        try transaction.serialize(to: &writer)
    }

    public init(from reader: inout BinaryReader) throws {
        signatures = try .init(from: &reader)
        transaction = try .init(from: &reader)
    }
}
