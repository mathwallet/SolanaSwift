//
//  SolanaInstructionAssetOwner.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssetOwner: SolanaInstructionBase {
    public var promgramId: SolanaPublicKey = SolanaPublicKey.OWNERVALIDATIONPROGRAMID
    public var signers: [SolanaSigner]
    
    public init(destination: SolanaPublicKey) {
        self.signers = [
            SolanaSigner(publicKey: destination, isSigner: false, isWritable: false)
        ]
    }
}

extension SolanaInstructionAssetOwner: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(SolanaPublicKey.OWNERPROGRAMID.data)
    }
    
    public init(from reader: inout BinaryReader) throws {
        guard try SolanaPublicKey.init(from: &reader) == SolanaPublicKey.OWNERPROGRAMID else {
            reader.cursor -= SolanaPublicKey.Size
            throw BorshDecodingError.unknownData
        }
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
