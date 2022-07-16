//
//  SolanaInstructionRaw.swift
//  
//
//  Created by math on 2021/11/9.
//

import Foundation

public struct SolanaInstructionRaw {
    
    public let promgramId: SolanaPublicKey
    public let signers: [SolanaSigner]
    public let data: Data
    
    public init(promgramId: SolanaPublicKey, signers: [SolanaSigner] = [], data: Data = Data()) {
        self.promgramId = promgramId
        self.signers = signers
        self.data = data
    }
}

extension SolanaInstructionRaw: SolanaInstructionBase {
    public func getSigners() -> [SolanaSigner] {
        return signers
    }
    
    public func getPromgramId() -> SolanaPublicKey {
        return promgramId
    }
}

extension SolanaInstructionRaw: SolanaHumanReadable {
    public func toHuman() -> Any {
//        if promgramId == SolanaPublicKey.OWNERPROGRAMID {
//            let type = data.readUInt32(at: 0)
//            // SolanaInstructionTransfer
//            if type == 2,
//                let i = SolanaInstructionTransfer(promgramId: promgramId, signers: signers, data: data) {
//                return i.toHuman()
//            }
//        } else if promgramId == SolanaPublicKey.TOKENPROGRAMID {
//            let type = data.readUInt8(at: 0)
//            // SolanaInstructionToken
//            if type == 3,
//                let i = SolanaInstructionToken(promgramId: promgramId, signers: signers, data: data) {
//                return i.toHuman()
//            }
//        } else if promgramId == SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID {
//            // SolanaInstructionAssociatedAccount
//            if let i = SolanaInstructionAssociatedAccount(promgramId: promgramId, signers: signers, data: data) {
//                return i.toHuman()
//            }
//        } else if promgramId == SolanaPublicKey.OWNERVALIDATIONPROGRAMID {
//            // SolanaInstructionAssetOwner
//            if let i = SolanaInstructionAssetOwner(promgramId: promgramId, signers: signers, data: data){
//                return i.toHuman()
//            }
//        }
//        var dataDic:[String:String] = [String:String]()
//        for i in 0..<self.signers.count {
//            dataDic["pubkey\(i)"] = self.signers[i].publicKey.address
//        }
//        dataDic["data"] = self.data.toHexString()
        return [
            "type": "Unknown Type",
            "data": []
        ]
    }
}
