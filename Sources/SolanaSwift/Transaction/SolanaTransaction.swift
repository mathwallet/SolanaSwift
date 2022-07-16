//
//  SolanaTransaction.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import Base58Swift
import CryptoSwift

public typealias SolanaInstruction = SolanaInstructionBase & BorshCodable & SolanaHumanReadable

public struct SolanaTransaction {
    public var instructions = [SolanaInstruction]()
    public var recentBlockhash = ""
    
    public var sortedSigners: [SolanaSigner] {
        var tempSigners = [SolanaSigner]()
        tempSigners.append(contentsOf: self.instructions.flatMap({ $0.getSigners() }))
        tempSigners.append(contentsOf: self.instructions.map({ SolanaSigner(publicKey: $0.getPromgramId()) }))
        
        // 排序
        let soredArray = tempSigners.sorted(by: >)
        
        // 去重
        var signers = [SolanaSigner]()
        for signer in soredArray {
            if !signers.contains(signer) {
                signers.append(signer)
            }
        }
        return signers
    }
    
    public init() {
    }
    
    public mutating func appendInstruction(instruction: SolanaInstruction) {
        self.instructions.append(instruction)
    }
    
    public func serializeAndBase58() throws -> String {
        return Base58.base58Encode(try BorshEncoder().encode(self).bytes)
    }
    
    public func sign(keypair: SolanaKeyPair) throws -> SolanaSignedTransaction {
        try self.sign(keypair: keypair, otherPairs: [])
    }
    
    public func sign(keypair: SolanaKeyPair, otherPairs: [SolanaKeyPair]) throws -> SolanaSignedTransaction {
        let digest = try BorshEncoder().encode(self)
        
        let signers = [keypair] + otherPairs
        
        var signatures = [SolanaSignature]()
        try signers.forEach { keyPair in
            signatures.append(SolanaSignature.init(data: try keyPair.signDigest(messageDigest: digest)))
        }
        return SolanaSignedTransaction(transaction: self, signatures: signatures)
    }
}

extension SolanaTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        let signers = self.sortedSigners
        
        let signCount = UInt8(signers.filter({ $0.isSigner }).count)
        let signOnlyCount = UInt8(signers.filter({ $0.isSigner && !$0.isWritable }).count)
        let readOnlyCount = UInt8(signers.filter({ !$0.isSigner && !$0.isWritable }).count)
        
        try signCount.serialize(to: &writer)
        try signOnlyCount.serialize(to: &writer)
        try readOnlyCount.serialize(to: &writer)
        
        try signers.serialize(to: &writer)
        
        writer.append(Data(Base58.base58Decode(self.recentBlockhash)!))
        
//        try instructions.serialize(to: &writer)
//        try UVarInt(instructions.count).serialize(to: &writer)
//        try instructions.forEach { instruction in
//            try UInt8(signers.map({ $0.publicKey }).firstIndex(of: instruction.promgramId)!).serialize(to: &writer)
//            
//            try UVarInt(instruction.signers.count).serialize(to: &writer)
//            try instruction.signers.forEach { signer in
//                try UInt8(signers.firstIndex(of: signer)!).serialize(to: &writer)
//            }
//            try UInt8(instruction.data.count).serialize(to: &writer)
//            writer.append(instruction.data)
//        }
    }

    public init(from reader: inout BinaryReader) throws {
        let signCount: UInt8 = try .init(from: &reader)
        let signOnlyCount: UInt8 = try .init(from: &reader)
        let readOnlyCount: UInt8 = try .init(from: &reader)
//        self.key = try .init(from: &reader)
//        self.update_authority = try .init(from: &reader)
//        self.mint = try .init(from: &reader)
//        self.data = try .init(from: &reader)
    }
}

extension SolanaTransaction: SolanaHumanReadable {
    
    public func serizlize() -> Data {
        let signers = self.sortedSigners
        var data = Data()
//        if !signatures.isEmpty {
//            data.appendVarInt(UInt64(signatures.count))
//            for signature in signatures {
//                data.append(signature.data)
//            }
//        }
//        data.appendUInt8(UInt8(signers.filter({ $0.isSigner }).count))
//        data.appendUInt8(UInt8(signers.filter({ $0.isSigner && !$0.isWritable }).count))
//        data.appendUInt8(UInt8(signers.filter({ !$0.isSigner && !$0.isWritable }).count))
//        data.appendUInt8(UInt8(signers.count))
//        for signer in signers {
//            data.append(signer.publicKey.data)
//        }
//        data.appendBytes(Base58.base58Decode(self.recentBlockhash)!)
//        data.appendVarInt(UInt64(self.instructions.count))
//        for instructionBase in self.instructions {
//            data.appendUInt8(UInt8(signers.map({ $0.publicKey }).firstIndex(of: instructionBase.promgramId)!))
//            data.appendVarInt(UInt64(instructionBase.signers.count))
//            for signer in instructionBase.signers {
//                data.appendUInt8(UInt8(signers.firstIndex(of: signer)!))
//            }
//            let instructionData = instructionBase.data
//            data.appendVarInt(UInt64(instructionData.count))
//            data.append(instructionData)
//        }
        return data
    }
    
    public func toHuman() -> Any {
        var messages: Dictionary<String, Any>  = [:]
        for (i, instruction) in self.instructions.enumerated() {
            messages["\(i)"] = instruction.toHuman()
        }
        return messages
    }
    
}

public struct SolanaSignedTransaction {
    let transaction: SolanaTransaction
    let signatures: [SolanaSignature]
}

extension SolanaSignedTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try signatures.serialize(to: &writer)
        try transaction.serialize(to: &writer)
    }

    public init(from reader: inout BinaryReader) throws {
        signatures = try .init(from: &reader)
        transaction = try .init(from: &reader)
    }
    
    public func serializeAndBase58() throws -> String {
        return Base58.base58Encode(try BorshEncoder().encode(self).bytes)
    }
}
