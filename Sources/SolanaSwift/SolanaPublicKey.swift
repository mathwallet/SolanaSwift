//
//  SolanaPublicKey.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import Base58Swift
import CryptoSwift
import CTweetNacl

public struct SolanaPublicKey {
    public static let Size: Int = 32
    
    public static let SYSTEM_PROGRAM_ID = SolanaPublicKey(base58String: "11111111111111111111111111111111")!
    public static let TOKEN_PROGRAM_ID = SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!
    public static let TOKEN2022_PROGRAM_ID = SolanaPublicKey(base58String: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb")!
    public static let MEMO_PROGRAM_ID = SolanaPublicKey(base58String: "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr")!
    public static let ASSOCIATED_TOKEN_PROGRAM_ID = SolanaPublicKey(base58String: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!
    public static let SYSVAR_RENT_PUBKEY = SolanaPublicKey(base58String: "SysvarRent111111111111111111111111111111111")!
    public static let SYSVAR_RECENT_BLOCK_HASHES_PUBKEY = SolanaPublicKey(base58String: "SysvarRecentB1ockHashes11111111111111111111")!
    public static let OWNER_VALIDATION_PROGRAM_ID = SolanaPublicKey(base58String: "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5")!
    public static let MATEDATA_PUBLICKEY = SolanaPublicKey(base58String: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")!
    public static let COMPUTE_BUDGET_PROGRAM_ID = SolanaPublicKey(base58String: "ComputeBudget111111111111111111111111111111")!
    
    public let data: Data
    public var address: String {
        return self.data.bytes.base58EncodedString
    }
    
    public init(data: Data) {
        self.data = data
    }
    
    public init?(base58String: String) {
        let data = base58String.base58DecodedData
        guard data.count == Self.Size else {
            return nil
        }
        self.init(data: data)
    }
}

extension SolanaPublicKey {
    public static func isValidAddress(_ address: String) -> Bool{
        let data = address.base58DecodedData
        guard data.count == Self.Size  else {
            return false
        }
        guard data.count == SolanaPublicKey.Size else {
            return false
        }
        return true
    }
}

extension SolanaPublicKey: Codable {
    public func encode(to encoder: any Encoder) throws {
        var signleValuedCont = encoder.singleValueContainer()
        try signleValuedCont.encode(self.address)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base58String = try container.decode(String.self)
        
        let data = base58String.base58DecodedData
        guard data.count == Self.Size else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid PublicKey")
        }
        self.init(data: data)
    }
}

extension SolanaPublicKey: Equatable {
    
    public static func == (lhs: SolanaPublicKey, rhs: SolanaPublicKey) -> Bool {
        return lhs.address == rhs.address
    }
    
}

extension SolanaPublicKey: CustomStringConvertible {
    public var description: String {
        return self.address
    }
}

extension SolanaPublicKey: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(self.data)
    }

    public init(from reader: inout BinaryReader) throws {
        self.data = Data(try reader.read(count: UInt32(SolanaPublicKey.Size)))
    }
}

extension SolanaPublicKey {
    
    public static func newAssociatedToken(pubkey: SolanaPublicKey, mint: SolanaPublicKey, tokenProgramID: SolanaPublicKey) -> SolanaPublicKey? {
        var i = 255
        while i > 0 {
            do {
                var data = Data()
                try pubkey.serialize(to: &data)
                try tokenProgramID.serialize(to: &data)
                try mint.serialize(to: &data)
                try UInt8(i).serialize(to: &data)
                try SolanaPublicKey.ASSOCIATED_TOKEN_PROGRAM_ID.serialize(to: &data)
                data.append("ProgramDerivedAddress".data(using: .utf8)!)
                
                let hashdata = data.sha256()
                if (is_on_curve(hashdata.bytes) == 0) {
                    return SolanaPublicKey(data: hashdata)
                }
            } catch _ {
            }
            i = i - 1
        }
        return nil
    }
    
    public static func createProgramAddress(mint: SolanaPublicKey) -> SolanaPublicKey? {
        var i = 255
        while i > 0 {
            do {
                var data = Data()
                data.append("metadata".data(using: .utf8)!)
                try SolanaPublicKey.MATEDATA_PUBLICKEY.serialize(to: &data)
                try mint.serialize(to: &data)
                try UInt8(i).serialize(to: &data)
                try SolanaPublicKey.MATEDATA_PUBLICKEY.serialize(to: &data)
                data.append("ProgramDerivedAddress".data(using: .utf8)!)
                
                let hashdata = data.sha256()
                if (is_on_curve(hashdata.bytes) == 0) {
                    return SolanaPublicKey(data: hashdata)
                }
            } catch _ {
            }
            i = i - 1
        }
        return nil
    }
    
    public static func createProgramAddress(seeds: Data, programId: SolanaPublicKey) -> SolanaPublicKey? {
        var i = 255
        while i > 0 {
            do {
                var data = Data()
                data.append(seeds)
                try UInt8(i).serialize(to: &data)
                try programId.serialize(to: &data)
                data.append("ProgramDerivedAddress".data(using: .utf8)!)
                
                let hashdata = data.sha256()
                if (is_on_curve(hashdata.bytes) == 0) {
                    return SolanaPublicKey(data: hashdata)
                }
            } catch _ {
            }
            i = i - 1
        }
        return nil
    }
}
