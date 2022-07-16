//
//  SolanaBlockHash.swift
//  
//
//  Created by mathwallet on 2022/7/16.
//

import Foundation
import Base58Swift
import CryptoSwift

public struct SolanaBlockHash {
    public static let EMPTY = SolanaBlockHash(data: Data(hex: "0000000000000000000000000000000000000000000000000000000000000000"))
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public init?(base58String: String) {
        guard let data = Base58.base58Decode(base58String) else {
            return nil
        }
        self.init(data: Data(data))
    }
}

extension SolanaBlockHash: CustomStringConvertible {
    public var description: String {
        return Base58.base58Encode(data.bytes)
    }
}

extension SolanaBlockHash: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(self.data)
    }

    public init(from reader: inout BinaryReader) throws {
        self.data = Data(reader.read(count: 32))
    }
}
