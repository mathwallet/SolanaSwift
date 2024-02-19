//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum SystemInstruction: BorshCodable {
    case Create(owner: SolanaPublicKey, lamports: UInt64, space: UInt64)
    case Assign(owner: SolanaPublicKey)
    case Transfer(lamports: UInt64)
    
    var type: UInt32 {
        switch self {
        case .Create:
            return 0
        case .Assign:
            return 1
        case .Transfer:
            return 2
        }
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.type.serialize(to: &writer)
        switch self {
        case .Create(let owner, let lamports, let space):
            try lamports.serialize(to: &writer)
            try space.serialize(to: &writer)
            try owner.serialize(to: &writer)
        case .Assign(let owner):
            try owner.serialize(to: &writer)
        case .Transfer(let lamports):
            try lamports.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let type = try UInt32.init(from: &reader)
        switch type {
        case 0:
            let owner = try SolanaPublicKey.init(from: &reader)
            let lamports = try UInt64.init(from: &reader)
            let space = try UInt64.init(from: &reader)
            self = .Create(owner: owner, lamports: lamports, space: space)
        case 1:
            let owner = try SolanaPublicKey.init(from: &reader)
            self = .Assign(owner: owner)
        case 2:
            let lamports = try UInt64.init(from: &reader)
            self = .Transfer(lamports: lamports)
        default:
            throw BorshDecodingError.unknownData
        }
    }
}

public struct SolanaProgramSystem: SolanaProgramBase {
    public let id: SolanaPublicKey = SolanaPublicKey.SYSTEM_PROGRAM_ID
    public var accounts: [SolanaSigner]
    public var instruction: SystemInstruction
    
    public static func create(from: SolanaPublicKey, new: SolanaPublicKey, owner: SolanaPublicKey, lamports: UInt64, space: UInt64) -> Self {
        return .init(
            accounts: [
                SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
                SolanaSigner(publicKey: new, isSigner: true, isWritable: true)
            ],
            instruction: .Create(owner: owner, lamports: lamports, space: space)
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
}
