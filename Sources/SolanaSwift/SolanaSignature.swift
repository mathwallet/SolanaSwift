//
//  SolanaSignature.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation
import Base58Swift

public struct SolanaSignature {
    public let data: Data
    
    public init(data: Data){
        self.data = data
    }
    
    public init?(base58String: String) {
        let decodeData = base58String.base58DecodedData
        guard decodeData.count == 64 else {
            return nil
        }
        self.data = Data(decodeData)
    }
    
    public func base58Sting() -> String {
        return self.data.bytes.base58EncodedString
    }
}

extension SolanaSignature: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(data)
    }

    public init(from reader: inout BinaryReader) throws {
        self.data = Data(reader.read(count: 64))
    }
}
