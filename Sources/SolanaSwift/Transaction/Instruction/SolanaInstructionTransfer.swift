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
    
    public var signers = [SolanaSigner]()
    
    public var data = Data()
    
    public init?(promgramId: SolanaPublicKey, signers: [SolanaSigner], data: Data) {
        self.promgramId = promgramId
        self.signers = signers
        self.data = data
    }
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, lamports: BigUInt) {
        self.signers.append(SolanaSigner(publicKey: from, isSigner: true, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: to, isSigner: false, isWritable: true))
        
        self.data = toData(lamports: lamports)
    }
    
    private func toData(lamports: BigUInt) -> Data {
        var data = Data()
        // InstructionType
        data.appendUInt32(2)
        data.appendUInt64(UInt64(lamports.description)!)
        return data
    }
}

extension SolanaInstructionTransfer: SolanaHumanReadable {
    public func toHuman() -> Dictionary<String, Any> {
        
        var from = ""
        var to = ""
        self.signers.forEach({ signer in
            if signer.isSigner {
                from = signer.publicKey.address
            } else {
                to = signer.publicKey.address
            }
        })
        let lamports = self.data.readUInt64(at: 4)
        return [
            "type": "Transfer",
            "data": [
                "from":from,
                "to":to,
                "lamports":"\(lamports)"
            ]
        ]
    }
}
