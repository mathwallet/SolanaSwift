//
//  SolanaInstructionToken2022.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/24.
//

import Foundation
import BigInt

public struct SolanaInstructionToken2022: SolanaInstructionBase {
    public var programId: SolanaPublicKey = SolanaPublicKey.TOKEN2022_PROGRAM_ID
    public var signers: [SolanaSigner]
    private let lamports: BigUInt
    private let decimal: BigUInt
    
    public init(from: SolanaPublicKey, to: SolanaPublicKey, lamports: BigUInt, decimal: BigUInt) {
        self.signers = [
            SolanaSigner(publicKey: from, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: to, isSigner: false, isWritable: true)
        ]
        self.lamports = lamports
        self.decimal = decimal
    }
}

extension SolanaInstructionToken2022: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        // Instruction Type
        try UInt8(12).serialize(to: &writer)
        try UInt64(lamports.description)!.serialize(to: &writer)
        try UInt8(decimal.description)!.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        // Instruction Type
        guard try UInt32.init(from: &reader)  == 12 else {
            throw BorshDecodingError.unknownData
        }
        signers = []
        lamports = BigUInt(try UInt64.init(from: &reader))
        decimal = BigUInt(try UInt8.init(from: &reader))
    }
}

extension SolanaInstructionToken2022: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "TransferChecked",
            "programId": programId.address,
            "data": [
                "lamports": lamports.description,
                "decimal": decimal.description
            ]
        ]
    }
}
