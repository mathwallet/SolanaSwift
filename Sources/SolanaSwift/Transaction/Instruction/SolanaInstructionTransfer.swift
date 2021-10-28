//
//  SolanaInstructionTransfer.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/24.
//

import Foundation
import BigInt

public struct SolanaInstructionTransfer: SolanaInstructionBase {
    public var instructionType: UInt32
    
    public var promgramId: SolanaPublicKey
    
    public var signers = [SolanaSigner]()
    
    public var lamports: BigUInt
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, lamports:BigUInt) {
        self.signers.append(SolanaSigner(publicKey: from, isSigner: true, isWritable: true))
        self.signers.append(SolanaSigner(publicKey: to, isSigner: false, isWritable: true))
        self.lamports = lamports
        self.instructionType = 2
        self.promgramId = SolanaPublicKey.OWNERPROGRAMID
    }
    
    public func toData() -> Data {
        var data = Data()
        data.appendUInt32(self.instructionType)
        data.appendUInt64(UInt64(self.lamports.description)!)
        return data
    }
}
