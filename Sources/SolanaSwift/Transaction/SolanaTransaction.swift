//
//  SolanaTransaction.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import Base58Swift
import CryptoSwift

public struct SolanaTransaction {
    public var instructions = [SolanaInstruction]()
    public var recentBlockhash: SolanaBlockHash = .EMPTY
    public var feePayer: SolanaPublicKey?
    
    public var sortedSigners: [SolanaSigner] {
        var tempSigners = [SolanaSigner]()
        tempSigners.append(contentsOf: self.instructions.flatMap({ $0.signers }))
        tempSigners.append(contentsOf: self.instructions.map({ SolanaSigner(publicKey: $0.programId) }))
        
        // 去重
        var uniqueSigners = [SolanaSigner]()
        for s in tempSigners {
            if let i = uniqueSigners.firstIndex(of: s){
                uniqueSigners[i].isSigner = uniqueSigners[i].isSigner || s.isSigner
                uniqueSigners[i].isWritable = uniqueSigners[i].isWritable || s.isWritable
            } else {
                uniqueSigners.append(s)
            }
        }
        
        // 排序
        var soredArray = uniqueSigners.sorted(by: <)
        
        // Move fee payer to the front
        if let payer = feePayer, let i = soredArray.map({ $0.publicKey }).firstIndex(of: payer), i > 0 {
            soredArray.remove(at: i)
            soredArray.insert(SolanaSigner(publicKey: payer, isSigner: true, isWritable: true), at: 0)
        }
      
        return soredArray
    }
    
    public init() {
    }
    
    public mutating func appendInstruction(instruction: SolanaInstruction) {
        self.instructions.append(instruction)
    }
    
    public mutating func appendInstructions(instructions: [SolanaInstruction]) {
        self.instructions.append(contentsOf: instructions)
    }
    
    public mutating func sign(keypair: SolanaKeyPair) throws -> SolanaSignedTransaction {
        try self.sign(keypair: keypair, otherPairs: [])
    }
    
    public mutating func sign(keypair: SolanaKeyPair, otherPairs: [SolanaKeyPair]) throws -> SolanaSignedTransaction {
        self.feePayer = keypair.publicKey
        let digest = try BorshEncoder().encode(self)
        
        let keypairs = [keypair] + otherPairs
        
        var signatures = [SolanaSignature]()
        for keyPair in keypairs {
            signatures.append(SolanaSignature.init(data: try keyPair.signDigest(messageDigest: digest)))
        }
        return SolanaSignedTransaction(transaction: self, signatures: signatures)
    }
}

extension SolanaTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        let signers = self.sortedSigners
        
        let signCount = UInt8(signers.filter({ $0.isSigner }).count)
        let signAndReadCount = UInt8(signers.filter({ $0.isSigner && !$0.isWritable }).count)
        let readonlyCount = UInt8(signers.filter({ !$0.isSigner && !$0.isWritable }).count)
        
        try signCount.serialize(to: &writer)
        try signAndReadCount.serialize(to: &writer)
        try readonlyCount.serialize(to: &writer)
        
        let publicKeys = signers.map({$0.publicKey})
        try publicKeys.serialize(to: &writer)
        
        try recentBlockhash.serialize(to: &writer)
        
        try UVarInt(instructions.count).serialize(to: &writer)
        for instruction in instructions {
            try UInt8(publicKeys.firstIndex(of: instruction.programId)!).serialize(to: &writer)
            
            try UVarInt(instruction.signers.count).serialize(to: &writer)
            for signer in instruction.signers {
                try UInt8(signers.firstIndex(of: signer)!).serialize(to: &writer)
            }
            
            var data = Data()
            try instruction.serialize(to: &data)
            
            try UVarInt(data.count).serialize(to: &writer)
            writer.append(data)
        }
    }

    public init(from reader: inout BinaryReader) throws {
        let signCount: UInt8 = try .init(from: &reader)
        let signAndReadCount: UInt8 = try .init(from: &reader)
        let readonlyCount: UInt8 = try .init(from: &reader)
        
        let publicKeys: [SolanaPublicKey] = try .init(from: &reader)
        self.recentBlockhash = try .init(from: &reader)
        
        var instructions = [SolanaInstruction]()
        let instructionCount = try UVarInt.init(from: &reader).value
        for _ in 0..<instructionCount {
            let programIdIndex: UInt8 = try .init(from: &reader)
            let programId = publicKeys[Int(programIdIndex)]
            
            let keyCount = try UVarInt.init(from: &reader).value
            var signers = [SolanaSigner]()
            for _ in 0..<keyCount {
                let i: UInt8 = try .init(from: &reader)
                let isWritable = ( (i >= 0 && i < Int(signCount) - Int(signAndReadCount)) || (i >= signCount && i < publicKeys.count - Int(readonlyCount)))
                signers.append(SolanaSigner(publicKey: publicKeys[Int(i)], isSigner: i < signCount, isWritable: isWritable ))
            }
            let dataCount = try UVarInt.init(from: &reader).value
            let data = Data(try reader.read(count: dataCount))
            
            let decodeInstruction = SolanaInstructionDecoder.decode(programId: programId, data: data, signers: signers)
            instructions.append(decodeInstruction)
        }
        self.instructions = instructions
    }
}

extension SolanaTransaction: SolanaHumanReadable {
    
    public func toHuman() -> Any {
        return [
            "instructions": instructions.map({$0.toHuman()}),
            "recentBlockhash": recentBlockhash.description
        ]
    }
    
}

public struct SolanaSignedTransaction {
    public let transaction: SolanaTransaction
    public let signatures: [SolanaSignature]
    
    public init(transaction: SolanaTransaction, signatures: [SolanaSignature]) {
        self.transaction = transaction
        self.signatures = signatures
    }
    
    public var signatureDatas: [Data] {
        return signatures.map({$0.data})
    }
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
        return try BorshEncoder().encode(self).byteArray.base58EncodedString
    }
}

extension SolanaSignedTransaction: SolanaHumanReadable {
    
    public func toHuman() -> Any {
        return [
            "transaction": transaction.toHuman(),
            "signature": signatures.map({$0.base58Sting()})
        ]
    }
    
}
