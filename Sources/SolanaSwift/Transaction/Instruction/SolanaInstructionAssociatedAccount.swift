//
//  SolanaInstructionAssociatedAccount.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssociatedAccount: SolanaInstructionBase {
    
    public var promgramId: SolanaPublicKey
    
    public var signers = [SolanaSigner]()
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, associatedToken: SolanaPublicKey, mint: SolanaPublicKey) {
        
        self.signers.append(SolanaSigner(publicKey: from, isSigner: true, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: associatedToken, isSigner: false, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: to))
        self.signers.append(SolanaSigner(publicKey: mint))
        self.signers.append(SolanaSigner(publicKey: SolanaPublicKey.OWNERPROGRAMID))
        self.signers.append(SolanaSigner(publicKey: SolanaPublicKey.TOKENPROGRAMID))
        self.signers.append(SolanaSigner(publicKey: SolanaPublicKey.SYSVARRENTPUBKEY))

        self.promgramId = SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID
    }
    
    public func toData() -> Data {
        return Data()
    }
}
