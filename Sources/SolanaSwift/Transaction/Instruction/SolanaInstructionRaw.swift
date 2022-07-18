//
//  SolanaInstructionRaw.swift
//  
//
//  Created by math on 2021/11/9.
//

import Foundation

public struct SolanaInstructionRaw: SolanaInstructionBase {
    
    public var promgramId: SolanaPublicKey
    public var signers: [SolanaSigner]
    public var data: Data
    
    public init(promgramId: SolanaPublicKey, signers: [SolanaSigner], data: Data) {
        self.promgramId = promgramId
        self.signers = signers
        self.data = data
    }
}

extension SolanaInstructionRaw: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(data)
    }
    
    public init(from reader: inout BinaryReader) throws {
        promgramId = SolanaPublicKey.SYSTEM_PROGRAM_ID
        signers = []
        data = Data()
    }
}

extension SolanaInstructionRaw: SolanaHumanReadable {
    public func toHuman() -> Any {
        return [
            "type": "Unknown Type",
            "promgramId": promgramId.address,
            "data": [
                "keys": signers.map({$0.publicKey.address})
            ]
        ]
    }
}
