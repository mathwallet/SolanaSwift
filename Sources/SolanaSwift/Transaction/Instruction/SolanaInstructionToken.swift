//
//  SolanaInstructionToken.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/26.
//

import Foundation
import BigInt

public struct SolanaInstructionToken: SolanaInstructionBase {
    public var promgramId: SolanaPublicKey = SolanaPublicKey.TOKENPROGRAMID
    
    public var signers = [SolanaSigner]()
    
    public var data = Data()
    
    
    public init?(promgramId: SolanaPublicKey, signers: [SolanaSigner], data: Data) {
        self.promgramId = promgramId
        self.signers = signers
        self.data = data
    }
    
    public init(tokenPub: SolanaPublicKey, destination: SolanaPublicKey, owner: SolanaPublicKey, lamports: BigUInt) {
        self.signers.append(SolanaSigner(publicKey: tokenPub, isSigner: false, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: destination, isSigner: false, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: owner, isSigner: true, isWritable: true))
        
        self.data = toData(lamports: lamports)
    }
    
    private func toData(lamports: BigUInt) -> Data {
        var data = Data()
        // Instruction Type
        data.appendUInt8(3)
        data.appendUInt64(UInt64(lamports.description)!)
        return data
    }
}

extension SolanaInstructionToken: SolanaHumanReadable {
    public func toHuman() -> Dictionary<String, Any> {
//        let type = self.data.readUInt8(at: 0)
        let lamports = self.data.readUInt64(at: 1)
        return [
            "type": "Transfer Token",
            "data": [
                "lamports": lamports
            ]
        ]
    }
}
