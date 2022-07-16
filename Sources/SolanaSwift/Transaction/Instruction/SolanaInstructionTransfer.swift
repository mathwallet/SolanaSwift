//
//  SolanaInstructionTransfer.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/24.
//

import Foundation
import BigInt

public struct SolanaInstructionTransfer: SolanaInstructionBase {
    public var promgramId: SolanaPublicKey = SolanaPublicKey.OWNERPROGRAMID
    public var signers: [SolanaSigner]
    private let lamports: BigUInt
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, lamports: BigUInt) {
        self.signers = [
            SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: to, isSigner: false, isWritable: true)
        ]
        self.lamports = lamports
    }
}

extension SolanaInstructionTransfer: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        // Instruction Type
        try UInt32(2).serialize(to: &writer)
        try UInt64(lamports.description)!.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        // Instruction Type
        guard try UInt32.init(from: &reader)  == 2 else {
            reader.cursor -= MemoryLayout<UInt32>.size
            throw BorshDecodingError.unknownData
        }
        signers = []
        lamports = BigUInt(try UInt64.init(from: &reader))
    }
}

extension SolanaInstructionTransfer: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Transfer",
            "promgramId": promgramId.address,
            "data": [
                "keys": signers.map({$0.publicKey.address}),
                "lamports": lamports.description
            ]
        ]
    }
}
