//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum SolanaProgramAssociatedTokenAccount: BorshCodable {
    case Create
    case CreateIdempotent
    case RecoverNested
    
    var type: UInt8 {
        switch self {
        case .Create:
            return 0
        case .CreateIdempotent:
            return 1
        case .RecoverNested:
            return 2
        }
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.type.serialize(to: &writer)
        switch self {
        case .Create, .CreateIdempotent, .RecoverNested:
            break
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let type = try UInt8.init(from: &reader)
        switch type {
        case 0:
            self = .Create
        case 1:
            self = .CreateIdempotent
        case 2:
            self = .RecoverNested
        default:
            throw BorshDecodingError.unknownData
        }
    }
}

extension SolanaProgramAssociatedTokenAccount: SolanaBaseProgram {
    public static var id: SolanaPublicKey = .ASSOCIATED_TOKEN_PROGRAM_ID
    
    public static func create(funder: SolanaPublicKey, associatedToken: SolanaPublicKey, owner: SolanaPublicKey, mint: SolanaPublicKey, tokenProgramID: SolanaPublicKey) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: funder, isSigner: true, isWritable: true),
                SolanaSigner(publicKey: associatedToken, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: owner, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: mint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSTEM_PROGRAM_ID, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: tokenProgramID, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false)
            ],
            data: Self.Create
        )
    }
    
    public static func createIdempotent(funder: SolanaPublicKey, associatedTokenAccount: SolanaPublicKey, owner: SolanaPublicKey, mint: SolanaPublicKey, tokenProgramID: SolanaPublicKey) throws -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: funder, isSigner: true, isWritable: true),
                SolanaSigner(publicKey: associatedTokenAccount, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: owner, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: mint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSTEM_PROGRAM_ID, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: tokenProgramID, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false)
            ],
            data: Self.CreateIdempotent
        )
    }
    
    public static func recoverNested(owner: SolanaPublicKey, ownerMint: SolanaPublicKey, ownerAssociatedTokenAccount: SolanaPublicKey, nestedMint: SolanaPublicKey, nestedMintAssociatedTokenAccount: SolanaPublicKey, destinationAssociatedTokenAccount: SolanaPublicKey, tokenProgramID: SolanaPublicKey) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: nestedMintAssociatedTokenAccount, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: nestedMint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: destinationAssociatedTokenAccount, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: ownerAssociatedTokenAccount, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: ownerMint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: owner, isSigner: true, isWritable: true),
                SolanaSigner(publicKey: tokenProgramID, isSigner: false, isWritable: false)
            ],
            data: Self.RecoverNested
        )
    }
}
