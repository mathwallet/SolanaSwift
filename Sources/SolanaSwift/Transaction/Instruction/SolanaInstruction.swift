//
//  SolanaInstuctionBase.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation

public protocol SolanaInstructionBase {
    var signers: [SolanaSigner] { set get }
    var programId: SolanaPublicKey { get }
}

public typealias SolanaInstruction = SolanaInstructionBase & BorshCodable & SolanaHumanReadable

public struct SolanaInstructionDecoder {
    static func decode(programId: SolanaPublicKey, data: Data, signers: [SolanaSigner]) -> SolanaInstruction {
        if programId == SolanaPublicKey.SYSTEM_PROGRAM_ID {
            // SolanaInstructionTransfer
            if var i = try? BorshDecoder.decode(SolanaInstructionTransfer.self, from: data) {
                i.signers = signers
                return i
            }
        } else if programId == SolanaPublicKey.TOKEN_PROGRAM_ID {
            // SolanaInstructionToken
            if var i = try? BorshDecoder.decode(SolanaInstructionToken.self, from: data) {
                i.signers = signers
                return i
            }
        } else if programId == SolanaPublicKey.ASSOCIATED_TOKEN_PROGRAM_ID {
            // SolanaInstructionAssociatedAccount
            if var i = try? BorshDecoder.decode(SolanaInstructionAssociatedAccount.self, from: data){
                i.signers = signers
                return i
            }
        } else if programId == SolanaPublicKey.OWNER_VALIDATION_PROGRAM_ID {
            // SolanaInstructionAssetOwner
            if var i = try? BorshDecoder.decode(SolanaInstructionAssetOwner.self, from: data) {
                i.signers = signers
                return i
            }
        } else if programId == SolanaPublicKey.TOKEN2022_PROGRAM_ID {
            if var i = try? BorshDecoder.decode(SolanaInstructionToken2022.self, from: data) {
                i.signers = signers
                return i
            }
        }
        return SolanaInstructionRaw(programId: programId, signers: signers, data: data)
    }
}
