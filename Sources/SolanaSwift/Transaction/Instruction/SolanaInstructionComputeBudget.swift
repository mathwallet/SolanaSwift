//
//  SolanaInstructionToken.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/26.
//

import Foundation
import BigInt

public enum ComputeBudget {
    case RequestUnits(units: BigUInt, additionalFee: BigUInt)
    case RequestHeapFrame(bytes: BigUInt)
    case SetComputeUnitLimit(units: BigUInt)
    case SetComputeUnitPrice(microLamports: BigUInt)
    
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
}

extension ComputeBudget: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        try type.serialize(to: &writer)
        switch self {
        case .RequestUnits(let units, let additionalFee):
            try UInt32(units.description)!.serialize(to: &writer)
            try UInt32(additionalFee.description)!.serialize(to: &writer)
        case .RequestHeapFrame(let bytes):
            try UInt32(bytes.description)!.serialize(to: &writer)
        case .SetComputeUnitLimit(let units):
            try UInt32(units.description)!.serialize(to: &writer)
        case .SetComputeUnitPrice(let microLamports):
            try UInt64(microLamports.description)!.serialize(to: &writer)
        }
    }
}


extension ComputeBudget: SolanaHumanReadable {
    public func toHuman() -> Any {
        switch self {
        case .RequestUnits(let units, let additionalFee):
            return [
                "type": "RequestUnits",
                "units": units.description,
                "additionalFee": additionalFee.description
            ]
        case .RequestHeapFrame(let bytes):
            return [
                "type": "RequestHeapFrame",
                "bytes": bytes.description
            ]
        case .SetComputeUnitLimit(let units):
            return [
                "type": "SetComputeUnitLimit",
                "units": units.description
            ]
        case .SetComputeUnitPrice(let microLamports):
            return [
                "type": "SetComputeUnitPrice",
                "microLamports": microLamports.description
            ]
        }
    }
}

public struct SolanaInstructionComputeBudget: SolanaInstructionBase {
    public let programId: SolanaPublicKey = SolanaPublicKey.COMPUTE_BUDGET_PROGRAM_ID
    public var signers: [SolanaSigner] = []
    
    public let computeBudget: ComputeBudget

    public init(computeBudget: ComputeBudget) {
        self.computeBudget = computeBudget
    }
}

extension SolanaInstructionComputeBudget: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try computeBudget.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
            let type = try UInt8.init(from: &reader)
            switch type {
            case 0:
                let units_u32 = try UInt32.init(from: &reader)
                let additionalFee_u32 = try UInt32.init(from: &reader)
                self.computeBudget = .RequestUnits(units: BigUInt(units_u32), additionalFee: BigUInt(additionalFee_u32))
            case 1:
                let bytes_u32 = try UInt32.init(from: &reader)
                self.computeBudget = .RequestHeapFrame(bytes: BigUInt(bytes_u32))
            case 2:
                let units_u32 = try UInt32.init(from: &reader)
                self.computeBudget = .SetComputeUnitLimit(units: BigUInt(units_u32))
            case 3:
                let microLamports_u64 = try UInt32.init(from: &reader)
                self.computeBudget = .SetComputeUnitPrice(microLamports: BigUInt(microLamports_u64))
            default:
                throw BorshDecodingError.unknownData
            }
    }
}

extension SolanaInstructionComputeBudget: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Compute Budget",
            "programId": programId.address,
            "data": computeBudget.toHuman()
        ]
    }
}
