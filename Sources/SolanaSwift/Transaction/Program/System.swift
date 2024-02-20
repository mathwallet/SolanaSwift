//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum SystemInstruction: BorshCodable {
    case CreateAccount(owner: SolanaPublicKey, lamports: UInt64, space: UInt64)
    case Assign(owner: SolanaPublicKey)
    case Transfer(lamports: UInt64)
    case InitializeNonceAccount(auth: SolanaPublicKey)
    case Allocate(space: UInt64)
    
    var type: UInt32 {
        switch self {
        case .CreateAccount:
            return 0
        case .Assign:
            return 1
        case .Transfer:
            return 2
        case .InitializeNonceAccount:
            return 6
        case .Allocate:
            return 8
        }
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.type.serialize(to: &writer)
        switch self {
        case .CreateAccount(let owner, let lamports, let space):
            try lamports.serialize(to: &writer)
            try space.serialize(to: &writer)
            try owner.serialize(to: &writer)
        case .Assign(let owner):
            try owner.serialize(to: &writer)
        case .Transfer(let lamports):
            try lamports.serialize(to: &writer)
        case .InitializeNonceAccount(let auth):
            try auth.serialize(to: &writer)
        case .Allocate(let space):
            try space.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let type = try UInt32.init(from: &reader)
        switch type {
        case 0:
            let owner = try SolanaPublicKey.init(from: &reader)
            let lamports = try UInt64.init(from: &reader)
            let space = try UInt64.init(from: &reader)
            self = .CreateAccount(owner: owner, lamports: lamports, space: space)
        case 1:
            let owner = try SolanaPublicKey.init(from: &reader)
            self = .Assign(owner: owner)
        case 2:
            let lamports = try UInt64.init(from: &reader)
            self = .Transfer(lamports: lamports)
        case 6:
            let auth = try SolanaPublicKey.init(from: &reader)
            self = .InitializeNonceAccount(auth: auth)
        case 8:
            let space = try UInt64.init(from: &reader)
            self = .Allocate(space: space)
        default:
            throw BorshDecodingError.unknownData
        }
    }
}

public struct SolanaProgramSystem: SolanaProgramBase {
    public let id: SolanaPublicKey = SolanaPublicKey.SYSTEM_PROGRAM_ID
    public var accounts: [SolanaSigner]
    public var instruction: SystemInstruction
    
    public static func CreateAccount(from: SolanaPublicKey, new: SolanaPublicKey, owner: SolanaPublicKey, lamports: UInt64, space: UInt64) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
                SolanaSigner(publicKey: new, isSigner: true, isWritable: true)
            ],
            instruction: .CreateAccount(owner: owner, lamports: lamports, space: space)
        )
    }
    
    public static func assign(from: SolanaPublicKey, owner: SolanaPublicKey) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: from, isSigner: true, isWritable: true)
            ],
            instruction: .Assign(owner: owner)
        )
    }
    
    public static func transfer(from: SolanaPublicKey, to: SolanaPublicKey, lamports: UInt64) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
                SolanaSigner(publicKey: to, isSigner: false, isWritable: true)
            ],
            instruction: .Transfer(lamports: lamports)
        )
    }
    
    public static func initializeNonceAccount(nonce: SolanaPublicKey, auth: SolanaPublicKey) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: nonce, isSigner: false, isWritable: true),
                SolanaSigner(publicKey: .SYSVAR_RECENT_BLOCK_HASHES_PUBKEY, isSigner: false, isWritable: false),
                SolanaSigner(publicKey: .SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false)
            ],
            instruction: .InitializeNonceAccount(auth: auth)
        )
    }
    
    public static func allocate(account: SolanaPublicKey, space: UInt64) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: account, isSigner: true, isWritable: true)
            ],
            instruction: .Allocate(space: space)
        )
    }
}
