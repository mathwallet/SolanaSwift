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
        if promgramId == SolanaPublicKey.SYSTEM_PROGRAM_ID {
            // SolanaInstructionTransfer
            if var i = try? SolanaInstructionTransfer.init(from: &reader) {
                i.signers = signers
                return i
            }
            // reader.cursor = 0
        } else if promgramId == SolanaPublicKey.TOKEN_PROGRAM_ID {
            // SolanaInstructionToken
            if var i = try? SolanaInstructionToken.init(from: &reader) {
                i.signers = signers
                return i
            }
            // reader.cursor = 0
        } else if promgramId == SolanaPublicKey.ASSOCIATED_TOKEN_PROGRAM_ID {
            // SolanaInstructionAssociatedAccount
            if var i = try? SolanaInstructionAssociatedAccount(from: &reader) {
                i.signers = signers
                return i
            }
            // reader.cursor = 0
        } else if promgramId == SolanaPublicKey.OWNER_VALIDATION_PROGRAM_ID {
            // SolanaInstructionAssetOwner
            if var i = try? SolanaInstructionAssetOwner(from: &reader) {
                i.signers = signers
                return i
            }
            // reader.cursor = 0
        }
        return SolanaInstructionRaw(promgramId: promgramId, signers: signers, data: data)
    }
}
