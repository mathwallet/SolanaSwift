//
//  SolanaInstructionTransfer.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/24.
//

import Foundation
import BigInt

public struct SolanaInstructionTransfer {
    public let from: SolanaPublicKey
    public let to: SolanaPublicKey
    public let lamports: BigUInt
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, lamports: BigUInt) {
        self.from = from
        self.to = to
        self.lamports = lamports
    }
}

extension SolanaInstructionTransfer: SolanaInstructionBase {
    public func getSigners() -> [SolanaSigner] {
        return [
            SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: to, isSigner: false, isWritable: true)
        ]
    }
    
    public func getPromgramId() -> SolanaPublicKey {
        return SolanaPublicKey.OWNERPROGRAMID
    }
}

extension SolanaInstructionTransfer: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        // Instruction Type
        try UInt32(2).serialize(to: &writer)
        try UInt64(lamports.description)!.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        from = SolanaPublicKey.MEMOPROGRAMID
        to = SolanaPublicKey.MEMOPROGRAMID
        lamports = BigUInt(0)
    }
}

extension SolanaInstructionTransfer: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Transfer",
            "data": [
                "from":from.address,
                "to": to.address,
                "lamports": lamports.description
            ]
        ]
    }
}
