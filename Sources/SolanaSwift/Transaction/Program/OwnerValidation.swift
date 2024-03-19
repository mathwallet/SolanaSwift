//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum SolanaProgramOwnerValidation: BorshCodable {
    case OwnerValidation(programId: SolanaPublicKey)

    public func serialize(to writer: inout Data) throws {
        switch self {
        case .OwnerValidation(let programId):
            try programId.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        self = .OwnerValidation(programId: try .init(from: &reader))
    }
}

extension SolanaProgramOwnerValidation: SolanaBaseProgram  {
    public static var id: SolanaPublicKey = SolanaPublicKey.OWNER_VALIDATION_PROGRAM_ID
    
    public static func createOwnerValidation(account: SolanaPublicKey, programId: SolanaPublicKey) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: [
                SolanaSigner(publicKey: account, isSigner: false, isWritable: false)
            ],
            data: Self.OwnerValidation(programId: programId)
        )
    }
}
