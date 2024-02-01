//
//  SolanaVersionedTransaction.swift
//
//
//  Created by mathwallet on 2024/2/1.
//

import Foundation

public struct SolanaVersionedTransaction {
    public var instructions = [SolanaInstruction]()
    public var recentBlockhash: SolanaBlockHash = .EMPTY
}

extension SolanaVersionedTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        
    }
    
    public init(from reader: inout BinaryReader) throws {
        let _: UInt8 = try .init(from: &reader)
        let signCount: UInt8 = try .init(from: &reader)
        let signAndReadCount: UInt8 = try .init(from: &reader)
        let readonlyCount: UInt8 = try .init(from: &reader)
        
        let publicKeys: [SolanaPublicKey] = try .init(from: &reader)
        self.recentBlockhash = try SolanaBlockHash.init(from: &reader)
        
        var instructions = [SolanaInstruction]()
        let instructionCount = try UVarInt.init(from: &reader).value
        for _ in 0..<instructionCount {
            let programIdIndex: UInt8 = try .init(from: &reader)
            let programId = publicKeys[Int(programIdIndex)]
            
            let keyCount = try UVarInt.init(from: &reader).value
            var signers = [SolanaSigner]()
            for _ in 0..<keyCount {
                let i: UInt8 = try .init(from: &reader)
                guard i < publicKeys.count else { continue }
                let isWritable = ( (i >= 0 && i < Int(signCount) - Int(signAndReadCount)) || (i >= signCount && i < publicKeys.count - Int(readonlyCount)))
                signers.append(SolanaSigner(publicKey: publicKeys[Int(i)], isSigner: i < signCount, isWritable: isWritable ))
            }
            let dataCount = try UVarInt.init(from: &reader).value
            let data = Data(reader.read(count: dataCount))
            
            let decodeInstruction = SolanaInstructionDecoder.decode(programId: programId, data: data, signers: signers)
            instructions.append(decodeInstruction)
        }
        self.instructions = instructions
    }
}

extension SolanaVersionedTransaction: SolanaHumanReadable {
    
    public func toHuman() -> Any {
        return [
            "instructions": instructions.map({$0.toHuman()}),
            "recentBlockhash": recentBlockhash.description
        ]
    }
    
}

public enum SolanaTransactionVersion: String {
    case legacy = "legacy"
    case v0 = "0"
}

public struct SolanaSignedVersionedTransaction {
    public let version: SolanaTransactionVersion
    public let transaction: BorshCodable
    public let signatures: [SolanaSignature]
    
    public init(transaction: SolanaVersionedTransaction, signatures: [SolanaSignature]) {
        self.version = .v0
        self.transaction = transaction
        self.signatures = signatures
    }
    
    public init(transaction: SolanaTransaction, signatures: [SolanaSignature]) {
        self.version = .legacy
        self.transaction = transaction
        self.signatures = signatures
    }
    
    public var signatureDatas: [Data] {
        return signatures.map({$0.data})
    }
}

extension SolanaSignedVersionedTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try signatures.serialize(to: &writer)
        try transaction.serialize(to: &writer)
    }

    public init(from reader: inout BinaryReader) throws {
        signatures = try .init(from: &reader)
        let prefix: UInt8 = reader.bytes[reader.cursor]
        let maskedPrefix: UInt8 = (prefix & 0x7f)
        if maskedPrefix != prefix, maskedPrefix == 0 {
            version = .v0
            transaction = try SolanaVersionedTransaction.init(from: &reader)
        } else {
            version = .legacy
            transaction = try SolanaTransaction.init(from: &reader)
        }
    }
    
    public func serializeAndBase58() throws -> String {
        return try BorshEncoder().encode(self).bytes.base58EncodedString
    }
}
