//
//  SolanaInstructionToken.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/26.
//

import Foundation
import BigInt

public struct SolanaInstructionToken {
    public let tokenPub: SolanaPublicKey
    public let destination: SolanaPublicKey
    public let owner: SolanaPublicKey
    public let lamports: BigUInt

    public init(tokenPub: SolanaPublicKey, destination: SolanaPublicKey, owner: SolanaPublicKey, lamports: BigUInt) {
        self.tokenPub = tokenPub
        self.destination = destination
        self.owner = owner
        self.lamports = lamports
    }
}

extension SolanaInstructionToken: SolanaInstructionBase {
    public func getPromgramId() -> SolanaPublicKey {
        return SolanaPublicKey.TOKENPROGRAMID
    }
    
    public func getSigners() -> [SolanaSigner] {
        return [
            SolanaSigner(publicKey: tokenPub, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: destination, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: owner, isSigner: true, isWritable: true)
        ]
    }
}

extension SolanaInstructionToken: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        // Instruction Type
        try UInt8(3).serialize(to: &writer)
        try UInt64(lamports.description)!.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        tokenPub = SolanaPublicKey.MEMOPROGRAMID
        destination = SolanaPublicKey.MEMOPROGRAMID
        owner = SolanaPublicKey.MEMOPROGRAMID
        lamports = BigUInt(0)
    }
}


extension SolanaInstructionToken: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Transfer Token",
            "data": [
                "tokenPub": tokenPub.address,
                "destination": destination.address,
                "owner": owner.address,
                "lamports": lamports.description
            ]
        ]
    }
}
