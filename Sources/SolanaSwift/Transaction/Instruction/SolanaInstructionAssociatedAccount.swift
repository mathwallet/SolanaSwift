//
//  SolanaInstructionAssociatedAccount.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssociatedAccount: SolanaInstructionBase {
    public var programId: SolanaPublicKey = SolanaPublicKey.ASSOCIATED_TOKEN_PROGRAM_ID
    public var signers: [SolanaSigner]
    
    public init(funding: SolanaPublicKey, wallet: SolanaPublicKey, associatedToken: SolanaPublicKey, mint: SolanaPublicKey) {
        self.signers = [
            SolanaSigner(publicKey: funding, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: associatedToken, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: wallet),
            SolanaSigner(publicKey: mint),
            SolanaSigner(publicKey: SolanaPublicKey.SYSTEM_PROGRAM_ID),
            SolanaSigner(publicKey: SolanaPublicKey.TOKEN_PROGRAM_ID),
            SolanaSigner(publicKey: SolanaPublicKey.SYSVAR_RENT_PUBKEY)
        ]
    }
}

extension SolanaInstructionAssociatedAccount: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        // Instruction Type
        try UInt8(0).serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        // Instruction Type
        guard try UInt8.init(from: &reader)  == 3 else {
            throw BorshDecodingError.unknownData
        }
        signers = []
    }
}

extension SolanaInstructionAssociatedAccount: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Associated Account",
            "programId": programId.address
        ]
    }
}
