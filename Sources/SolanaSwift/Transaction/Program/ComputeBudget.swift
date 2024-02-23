//
//  SolanaInstructionToken.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/26.
//

import Foundation
import BigInt

public enum SolanaProgramComputeBudget: BorshCodable {
    case RequestUnits(units: UInt32, additionalFee: UInt32)
    case RequestHeapFrame(bytes: UInt32)
    case SetComputeUnitLimit(units: UInt32)
    case SetComputeUnitPrice(microLamports: UInt64)
    
    var type: UInt8 {
        switch self {
        case .RequestUnits(_, _):
            return 0
        case .RequestHeapFrame(_):
            return 1
        case .SetComputeUnitLimit(_):
            return 2
        case .SetComputeUnitPrice(_):
            return 3
        }
    }
    
    public func serialize(to writer: inout Data) throws {
        try type.serialize(to: &writer)
        switch self {
        case .RequestUnits(let units, let additionalFee):
            try units.serialize(to: &writer)
            try additionalFee.serialize(to: &writer)
        case .RequestHeapFrame(let bytes):
            try bytes.serialize(to: &writer)
        case .SetComputeUnitLimit(let units):
            try units.serialize(to: &writer)
        case .SetComputeUnitPrice(let microLamports):
            try microLamports.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let type = try UInt8.init(from: &reader)
        switch type {
        case 0:
            let units = try UInt32.init(from: &reader)
            let additionalFee = try UInt32.init(from: &reader)
            self = .RequestUnits(units: units, additionalFee: additionalFee)
        case 1:
            let bytes = try UInt32.init(from: &reader)
            self = .RequestHeapFrame(bytes: bytes)
        case 2:
            let units = try UInt32.init(from: &reader)
            self = .SetComputeUnitLimit(units: units)
        case 3:
            let microLamports = try UInt64.init(from: &reader)
            self = .SetComputeUnitPrice(microLamports: microLamports)
        default:
            throw BorshDecodingError.unknownData
        }
    }
}

extension SolanaProgramComputeBudget: SolanaBaseProgram {
    public static var id: SolanaPublicKey = SolanaPublicKey.COMPUTE_BUDGET_PROGRAM_ID
    
    public static func requestUnits(units: UInt32, additionalFee: UInt32) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [],
            data: Self.RequestUnits(units: units, additionalFee: additionalFee)
        )
    }
    
    public static func requestHeapFrame(bytes: UInt32) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [],
            data: Self.RequestHeapFrame(bytes: bytes)
        )
    }
    
    public static func setComputeUnitLimit(units: UInt32) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [],
            data: Self.SetComputeUnitLimit(units: units)
        )
    }
    
    public static func setComputeUnitPrice(microLamports: UInt64) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [],
            data: Self.SetComputeUnitPrice(microLamports: microLamports)
        )
    }
}
