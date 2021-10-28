//
//  SolanaInstructionToken.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/26.
//

import Foundation
import BigInt

public struct SolanaInstructionToken: SolanaInstructionBase {
    public var instructionType: UInt8 = 3
    
    public var promgramId: SolanaPublicKey
    
    public var signers = [SolanaSigner]()
    
    public var lamports:BigUInt
    
    public init(tokenPub: SolanaPublicKey, destination: SolanaPublicKey, owner: SolanaPublicKey, lamports: BigUInt) {
        self.signers.append(SolanaSigner(publicKey: tokenPub, isSigner: false, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: destination, isSigner: false, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: owner, isSigner: true, isWritable: true))
        
        self.lamports = lamports
        self.promgramId = SolanaPublicKey.TOKENPROGRAMID
    }
    
    public func toData() -> Data {
        var data = Data()
        data.appendUInt8(self.instructionType)
        data.appendUInt64(UInt64(self.lamports.description)!)
        return data
    }
}
