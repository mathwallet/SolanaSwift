//
//  SolanaProgramSystem.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation
import BigInt

public enum SolanaProgramMemo: BorshCodable {
    case Build(memo: Data)

    public func serialize(to writer: inout Data) throws {
        switch self {
        case .Build(let memo):
            writer.append(memo)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        self = .Build(memo: Data(reader.bytes))
    }
}

extension SolanaProgramMemo: SolanaBaseProgram  {
    public static var id: SolanaPublicKey = SolanaPublicKey.MEMO_PROGRAM_ID
    
    public static func buildMemo(_ memo: Data, signerPubKeys: [SolanaPublicKey]) -> SolanaMessageInstruction {
        return .init(
            programId: Self.id,
            accounts: signerPubKeys.map({ SolanaSigner(publicKey: $0, isSigner: true, isWritable: false) }),
            data: Self.Build(memo: memo)
        )
    }
}
