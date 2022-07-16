//
//  SolanaInstructionAssociatedAccount.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssociatedAccount {
    public let from: SolanaPublicKey
    public let to: SolanaPublicKey
    public let associatedToken: SolanaPublicKey
    public let mint: SolanaPublicKey
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, associatedToken: SolanaPublicKey, mint: SolanaPublicKey) {
        self.from = from
        self.to = to
        self.associatedToken = associatedToken
        self.mint = mint
    }
}

extension SolanaInstructionAssociatedAccount: SolanaInstructionBase {
    public func getSigners() -> [SolanaSigner] {
        return [
            SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: associatedToken, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: to),
            SolanaSigner(publicKey: mint),
            SolanaSigner(publicKey: SolanaPublicKey.OWNERPROGRAMID),
            SolanaSigner(publicKey: SolanaPublicKey.TOKENPROGRAMID),
            SolanaSigner(publicKey: SolanaPublicKey.SYSVARRENTPUBKEY)
        ]
    }
    
    public func getPromgramId() -> SolanaPublicKey {
        return SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID
    }
}

extension SolanaInstructionAssociatedAccount: BorshCodable {
    public func serialize(to writer: inout Data) throws {
    }
    
    public init(from reader: inout BinaryReader) throws {
        from = SolanaPublicKey.MEMOPROGRAMID
        to = SolanaPublicKey.MEMOPROGRAMID
        associatedToken = SolanaPublicKey.MEMOPROGRAMID
        mint = SolanaPublicKey.MEMOPROGRAMID
    }
}

extension SolanaInstructionAssociatedAccount: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Associated Account",
            "data": [
                "from": from.address,
                "to": to.address,
                "associatedToken": associatedToken.address,
                "mint": mint.address
            ]
        ]
    }
}
