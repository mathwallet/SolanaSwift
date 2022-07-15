//
//  SolanaTransaction.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import Base58Swift

public typealias SolanaInstruction = SolanaInstructionBase & SolanaHumanReadable

public struct SolanaTransaction {
    public var instructions = [SolanaInstruction]()
    public var signatures = [SolanaSignature]()
    public var recentBlockhash = ""
    
    public init() {
    }
    
    public mutating func appendInstruction(instruction: SolanaInstruction) {
        self.instructions.append(instruction)
    }
    
    public func serializeAndBase58() -> String {
        return Base58.base58Encode(self.serizlize().bytes)
    }
    
    public mutating func sign(keypair:SolanaKeyPair) throws {
        try self.sign(keypair: keypair, otherPairs: [])
    }
    
    public mutating func sign(keypair:SolanaKeyPair, otherPairs: [SolanaKeyPair]) throws {
        let dataDigest = self.serizlize()
        self.signatures.removeAll()
        self.signatures.append(SolanaSignature.init(data:try keypair.signDigest(messageDigest: dataDigest)))
        for otherKeypair in otherPairs {
            self.signatures.append(SolanaSignature.init(data: try otherKeypair.signDigest(messageDigest: dataDigest)))
        }
    }
    
}

// MARK: - Serizlize & Deserialize

extension SolanaTransaction: SolanaHumanReadable {
    
    public func serizlize() -> Data {
        var tempSigners = [SolanaSigner]()
        tempSigners.append(contentsOf: self.instructions.flatMap({ $0.signers }))
        tempSigners.append(contentsOf: self.instructions.map({ SolanaSigner(publicKey: $0.promgramId) }))
        
        // 排序
        let soredArray = tempSigners.sorted(by: >)
        
        // 去重
        var signers = [SolanaSigner]()
        for signer in soredArray {
            if !signers.contains(signer) {
                signers.append(signer)
            }
        }
        
        var data = Data()
        if !signatures.isEmpty {
            data.appendVarInt(UInt64(signatures.count))
            for signature in signatures {
                data.append(signature.data)
            }
        }
        data.appendUInt8(UInt8(signers.filter({ $0.isSigner }).count))
        data.appendUInt8(UInt8(signers.filter({ $0.isSigner && !$0.isWritable }).count))
        data.appendUInt8(UInt8(signers.filter({ !$0.isSigner && !$0.isWritable }).count))
        data.appendUInt8(UInt8(signers.count))
        for signer in signers {
            data.append(signer.publicKey.data)
        }
        data.appendBytes(Base58.base58Decode(self.recentBlockhash)!)
        data.appendVarInt(UInt64(self.instructions.count))
        for instructionBase in self.instructions {
            data.appendUInt8(UInt8(signers.map({ $0.publicKey }).firstIndex(of: instructionBase.promgramId)!))
            data.appendVarInt(UInt64(instructionBase.signers.count))
            for signer in instructionBase.signers {
                data.appendUInt8(UInt8(signers.firstIndex(of: signer)!))
            }
            let instructionData = instructionBase.data
            data.appendVarInt(UInt64(instructionData.count))
            data.append(instructionData)
        }
        return data
    }
    
    public func toHuman() -> Dictionary<String, Any> {
        var messages: Dictionary<String, Any>  = [:]
        for (i, instruction) in self.instructions.enumerated() {
            messages["\(i)"] = instruction.toHuman()
        }
        return messages
    }
    
}
