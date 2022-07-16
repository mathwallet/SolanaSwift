//
//  SolanaInstructionAssetOwner.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation

public struct SolanaInstructionAssetOwner {
    public let destination: SolanaPublicKey
    
    public init(destination: SolanaPublicKey) {
        self.destination = destination
    }
    
    private func toData() -> Data {
        return Data(SolanaPublicKey.OWNERPROGRAMID.data)
    }
}

extension SolanaInstructionAssetOwner: SolanaInstructionBase {
    public func getSigners() -> [SolanaSigner] {
        return [
            SolanaSigner(publicKey: destination, isSigner: false, isWritable: false)
        ]
    }
    
    public func getPromgramId() -> SolanaPublicKey {
        return SolanaPublicKey.OWNERVALIDATIONPROGRAMID
    }
}

extension SolanaInstructionAssetOwner: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(SolanaPublicKey.OWNERPROGRAMID.data)
    }
    
    public init(from reader: inout BinaryReader) throws {
        destination = SolanaPublicKey.MEMOPROGRAMID
    }
}

extension SolanaInstructionAssetOwner: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Asset Owner",
            "data": [
                "destination":self.getSigners().first!.publicKey.address
            ]
        ]
    }
}
