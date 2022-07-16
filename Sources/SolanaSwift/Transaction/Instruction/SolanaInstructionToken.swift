//
//  SolanaInstructionToken.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/26.
//

import Foundation
import BigInt

public struct SolanaInstructionToken: SolanaInstructionBase {
    public let promgramId: SolanaPublicKey = SolanaPublicKey.TOKENPROGRAMID
    public var signers: [SolanaSigner]
    
    public let lamports: BigUInt

    public init(tokenPub: SolanaPublicKey, destination: SolanaPublicKey, owner: SolanaPublicKey, lamports: BigUInt) {
        self.signers = [
            SolanaSigner(publicKey: tokenPub, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: destination, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: owner, isSigner: true, isWritable: true)
        ]
        self.lamports = lamports
    }
}

extension SolanaInstructionToken: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        // Instruction Type
        try UInt8(3).serialize(to: &writer)
        try UInt64(lamports.description)!.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        // Instruction Type
        guard try UInt8.init(from: &reader)  == 3 else {
            reader.cursor -= MemoryLayout<UInt8>.size
            throw BorshDecodingError.unknownData
        }
        signers = []
        lamports = BigUInt(try UInt64.init(from: &reader))
    }
}


extension SolanaInstructionToken: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Transfer Token",
            "promgramId": promgramId.address,
            "data": [
                "keys": signers.map({$0.publicKey.address}),
                "lamports": lamports.description
            ]
        ]
    }
}
