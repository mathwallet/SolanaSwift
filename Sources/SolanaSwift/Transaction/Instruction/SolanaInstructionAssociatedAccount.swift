//
//  SolanaInstructionAssociatedAccount.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssociatedAccount: SolanaInstructionBase {
    public var promgramId: SolanaPublicKey = SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID
    public var signers: [SolanaSigner]
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, associatedToken: SolanaPublicKey, mint: SolanaPublicKey) {
        self.signers = [
            SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: associatedToken, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: to),
            SolanaSigner(publicKey: mint),
            SolanaSigner(publicKey: SolanaPublicKey.OWNERPROGRAMID),
            SolanaSigner(publicKey: SolanaPublicKey.TOKENPROGRAMID),
            SolanaSigner(publicKey: SolanaPublicKey.SYSVARRENTPUBKEY)
        ]
    }
}

extension SolanaInstructionAssociatedAccount: BorshCodable {
    public func serialize(to writer: inout Data) throws {
    }
    
    public init(from reader: inout BinaryReader) throws {
        signers = []
    }
}

extension SolanaInstructionAssociatedAccount: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Associated Account",
            "promgramId": promgramId.address,
            "data": signers.map({$0.publicKey.address})
        ]
    }
}
