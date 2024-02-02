//
//  SolanaInstructionRaw.swift
//  
//
//  Created by math on 2021/11/9.
//

import Foundation

public struct SolanaInstructionRaw: SolanaInstructionBase {
    
    public var programId: SolanaPublicKey
    public var signers: [SolanaSigner]
    public var data: Data
    
    public init(programId: SolanaPublicKey, signers: [SolanaSigner], data: Data) {
        self.programId = programId
        self.signers = signers
        self.data = data
    }
}

extension SolanaInstructionRaw: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(data)
    }
    
    public init(from reader: inout BinaryReader) throws {
        programId = SolanaPublicKey.SYSTEM_PROGRAM_ID
        signers = []
        data = Data()
    }
}

extension SolanaInstructionRaw: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Unknown Type",
            "programId": programId.address,
            "data": data.toHexString()
        ]
    }
}
