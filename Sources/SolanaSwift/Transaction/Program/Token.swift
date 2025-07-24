//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum SolanaProgramToken: BorshCodable {
    case InitializeMint(decimals: UInt8, authority: SolanaPublicKey, freezeAuthority: SolanaPublicKey?)
    case InitializeAccount
    case Transfer(amount: UInt64)
    case TransferChecked(amount: UInt64, decimal: UInt8)
    
    var type: UInt8 {
        switch self {
        case .InitializeMint:
            return 0
        case .InitializeAccount:
            return 1
        case .Transfer:
            return 3
        case .TransferChecked:
            return 12
        }
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.type.serialize(to: &writer)
        switch self {
        case .InitializeMint(let decimals, let authority, let freezeAuthority):
            try decimals.serialize(to: &writer)
            try authority.serialize(to: &writer)
            
            let freezeAuthorityOpt: Optional<SolanaPublicKey> = freezeAuthority
            try freezeAuthorityOpt.serialize(to: &writer)
        case .InitializeAccount:
            break
        case .Transfer(let amount):
            try amount.serialize(to: &writer)
        case .TransferChecked(let amount, let decimal):
            try amount.serialize(to: &writer)
            try decimal.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let type = try UInt8.init(from: &reader)
        switch type {
        case 0:
            let decimals = try UInt8.init(from: &reader)
            let authority = try SolanaPublicKey.init(from: &reader)
            let freezeAuthority = try Optional<SolanaPublicKey>.init(from: &reader)
            self = .InitializeMint(decimals: decimals, authority: authority, freezeAuthority: freezeAuthority)
        case 1:
            self = .InitializeAccount
        case 3:
            let amount = try UInt64.init(from: &reader)
            self = .Transfer(amount: amount)
        case 12:
            let amount = try UInt64.init(from: &reader)
            let decimal = try UInt8.init(from: &reader)
            self = .TransferChecked(amount: amount, decimal: decimal)
        default:
            throw BorshDecodingError.unknownData
        }
    }
}

extension SolanaProgramToken: SolanaBaseProgram  {
    public static var id: SolanaPublicKey = SolanaPublicKey.TOKEN_PROGRAM_ID
    public static var token2022id: SolanaPublicKey = SolanaPublicKey.TOKEN2022_PROGRAM_ID
    
    public static func initializeMint(mint: SolanaPublicKey, decimals: UInt8, authority: SolanaPublicKey, freezeAuthority: SolanaPublicKey?) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: mint, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: .SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false)
            ],
            data: Self.InitializeMint(decimals: decimals, authority: authority, freezeAuthority: freezeAuthority)
        )
    }
    
    public static func initializeAccount(account: SolanaPublicKey, mint: SolanaPublicKey, owner: SolanaPublicKey) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: account, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: mint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: owner, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false)
            ],
            data: Self.InitializeAccount
        )
    }
    
    public static func transfer(source: SolanaPublicKey, destination: SolanaPublicKey, owner: SolanaPublicKey, amount: UInt64) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: source, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: destination, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: owner, isSigner: true, isWritable: true)
            ],
            data: Self.Transfer(amount: amount)
        )
    }
    
    public static func transferChecked(source: SolanaPublicKey, destination: SolanaPublicKey, owner: SolanaPublicKey, mint: SolanaPublicKey, amount: UInt64, decimal: UInt8) -> SolanaMessageInstruction {
        return .init(
            programId: Self.token2022id,
            accounts: [
                SolanaSigner(publicKey: source, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: mint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: destination, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: owner, isSigner: true, isWritable: true)
            ],
            data: Self.TransferChecked(amount: amount, decimal: decimal)
        )
    }
}
