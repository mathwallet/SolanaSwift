//
//  SolanaInstuctionBase.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation

public protocol SolanaInstructionBase {
    var signers: [SolanaSigner] { set get }
    var promgramId: SolanaPublicKey { get }
}

public typealias SolanaInstruction = SolanaInstructionBase & BorshCodable & SolanaHumanReadable

public struct SolanaInstructionDecoder {
    static func decode(promgramId: SolanaPublicKey, data: Data, signers: [SolanaSigner]) -> SolanaInstruction {
        var reader = BinaryReader(bytes: data.bytes)
        if promgramId == SolanaPublicKey.OWNERPROGRAMID {
            // SolanaInstructionTransfer
            if var i = try? SolanaInstructionTransfer.init(from: &reader) {
                i.signers = signers
                return i
            }
        } else if promgramId == SolanaPublicKey.TOKENPROGRAMID {
            // SolanaInstructionToken
            if var i = try? SolanaInstructionToken.init(from: &reader) {
                i.signers = signers
                return i
            }
        } else if promgramId == SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID {
            // SolanaInstructionAssociatedAccount
            if var i = try? SolanaInstructionAssociatedAccount(from: &reader) {
                i.signers = signers
                return i
            }
        } else if promgramId == SolanaPublicKey.OWNERVALIDATIONPROGRAMID {
            // SolanaInstructionAssetOwner
            if var i = try? SolanaInstructionAssetOwner(from: &reader) {
                i.signers = signers
                return i
            }
        }
        return SolanaInstructionRaw(promgramId: promgramId, signers: signers, data: data)
    }
}
