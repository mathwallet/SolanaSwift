//
//  SolanaInstructionAssetOwner.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssetOwner: SolanaInstructionBase {
    
    public var promgramId: SolanaPublicKey
    
    public var signers = [SolanaSigner]()
    
    public init(destination: SolanaPublicKey) {
        self.signers.append(SolanaSigner(publicKey: destination, isSigner: false, isWritable: false))
        self.promgramId = SolanaPublicKey.OWNERVALIDATIONPROGRAMID
    }
    
    public func toData() -> Data {
            return Data(SolanaPublicKey.OWNERPROGRAMID.data)
    }
}
