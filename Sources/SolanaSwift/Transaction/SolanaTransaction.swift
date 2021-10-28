//
//  SolanaTransaction.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import Base58Swift

public struct SolanaTransaction {
    public var instructions = [SolanaInstructionBase]()
    public var signatures = [SolanaSignature]()
    public var recentBlockhash = ""
    
    public init() {
    }
    
    public mutating func appendInstruction(instruction:SolanaInstructionBase) {
        self.instructions.append(instruction)
    }
    
    private func toData() -> Data {
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
            data.appendVarInt(signatures.count)
            for signature in signatures {
                data.append(signature.toByte())
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
        data.appendVarInt(self.instructions.count)
        for instructionBase in self.instructions {
            data.appendUInt8(UInt8(signers.map({ $0.publicKey }).firstIndex(of: instructionBase.promgramId)!))
            data.appendVarInt(instructionBase.signers.count)
            for signer in instructionBase.signers {
                data.appendUInt8(UInt8(signers.firstIndex(of: signer)!))
            }
            let instructionData = instructionBase.toData()
            data.appendVarInt(instructionData.count)
            data.append(instructionData)
        }
        return data
    }
    
    public func serizlize() -> Data{
        return self.toData()
    }
    
    public func serializeAndBase58() -> String {
       return Base58.base58Encode(([UInt8])(self.toData()))
    }
    
    public mutating func sign(keypair:SolanaKeyPair)  {
        self.sign(keypair: keypair, otherPairs: [])
    }
    
    public mutating func sign(keypair:SolanaKeyPair,otherPairs:[SolanaKeyPair]) {
        let dataDigest = self.toData()
        self.signatures.removeAll()
        self.signatures.append(SolanaSignature.init(data:keypair.signDigest(messageDigest: dataDigest)))
        if !otherPairs.isEmpty {
            for otherKeypair in otherPairs {
                self.signatures.append(SolanaSignature.init(data:otherKeypair.signDigest(messageDigest: dataDigest)))
            }
        }
    }
    
}
    
