//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum TokenInstruction: BorshCodable {
    case InitializeAccount
    case Transfer(amount: UInt64)
    
    var type: UInt8 {
        switch self {
        case .InitializeAccount:
            return 1
        case .Transfer:
            return 3
        }
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.type.serialize(to: &writer)
        switch self {
        case .InitializeAccount:
            break
        case .Transfer(let amount):
            try amount.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let type = try UInt8.init(from: &reader)
        switch type {
        case 1:
            self = .InitializeAccount
        case 3:
            let amount = try UInt64.init(from: &reader)
            self = .Transfer(amount: amount)
        default:
            throw BorshDecodingError.unknownData
        }
    }
}

public struct SolanaProgramToken: SolanaProgramBase {
    public let id: SolanaPublicKey = SolanaPublicKey.TOKEN_PROGRAM_ID
    public var accounts: [SolanaSigner]
    public var instruction: TokenInstruction
    
    public static func initializeAccount(account: SolanaPublicKey, mint: SolanaPublicKey, owner: SolanaPublicKey) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: account, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: mint, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: owner, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false)
            ],
            instruction: .InitializeAccount
        )
    }
    
    public static func transfer(from: SolanaPublicKey, to: SolanaPublicKey, token: SolanaPublicKey, amount: UInt64) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: token, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: to, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: from, isSigner: true, isWritable: true)
            ],
            instruction: .Transfer(amount: amount)
        )
    }
}
