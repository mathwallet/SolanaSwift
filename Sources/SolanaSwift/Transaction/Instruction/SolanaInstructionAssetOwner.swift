//
//  SolanaInstructionAssetOwner.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssetOwner: SolanaInstructionBase {
    
    public var promgramId: SolanaPublicKey = SolanaPublicKey.OWNERVALIDATIONPROGRAMID
    
    public var signers = [SolanaSigner]()
    
    public var data = Data()
    
    public init?(promgramId: SolanaPublicKey, signers: [SolanaSigner], data: Data) {
        self.promgramId = promgramId
        self.signers = signers
        self.data = data
    }
    
    public init(destination: SolanaPublicKey) {
        self.signers.append(SolanaSigner(publicKey: destination, isSigner: false, isWritable: false))
        self.data = toData()
    }
    
    private func toData() -> Data {
        return Data(SolanaPublicKey.OWNERPROGRAMID.data)
    }
}

extension SolanaInstructionAssetOwner: SolanaHumanReadable {
    public func toHuman() -> Dictionary<String, Any> {
        return [
            "type": "Asset Owner",
            "data": [
                "destination":self.signers.first?.publicKey.address,
                "data":self.data.toHexString()
                    ]
        ]
    }
}
