//
//  SolanaInstructionAssetOwner.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssetOwner: SolanaInstructionBase {
    public var promgramId: SolanaPublicKey = SolanaPublicKey.OWNER_VALIDATION_PROGRAM_ID
    public var signers: [SolanaSigner]
    public let owner: SolanaPublicKey
    
    public init(destination: SolanaPublicKey, owner: SolanaPublicKey = .SYSTEM_PROGRAM_ID ) {
        self.owner = owner
        self.signers = [
            SolanaSigner(publicKey: destination, isSigner: false, isWritable: false)
        ]
    }
}

extension SolanaInstructionAssetOwner: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try owner.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        owner = try SolanaPublicKey.init(from: &reader)
        signers = []
    }
}

extension SolanaInstructionAssetOwner: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Asset Owner",
            "promgramId": promgramId.address,
            "data": [
                "keys": signers.map({$0.publicKey.address})
            ]
        ]
    }
}
