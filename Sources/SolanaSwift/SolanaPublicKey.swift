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
    
    public static let OWNERPROGRAMID = SolanaPublicKey(base58String: "11111111111111111111111111111111")!
    public static let TOKENPROGRAMID = SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!
    public static let MEMOPROGRAMID = SolanaPublicKey(base58String: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")!
    public static let ASSOCIATEDTOKENPROGRAMID = SolanaPublicKey(base58String: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!
    public static let SYSVARRENTPUBKEY = SolanaPublicKey(base58String: "SysvarRent111111111111111111111111111111111")!
    public static let OWNERVALIDATIONPROGRAMID = SolanaPublicKey(base58String: "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5")!
    public static let MATEDATAPUBLICKEY = SolanaPublicKey(base58String: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")!
    public let data: Data
    public var address:String {
        return Base58.base58Encode(self.data.bytes)
    }
    
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

extension SolanaPublicKey {
    public static func isValidAddress(_ address: String) -> Bool{
        guard let data = Base58.base58Decode(address)  else {
            return false
        }
        guard data.count == SolanaPublicKey.Size else {
            return false
        }
        return true
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

extension SolanaPublicKey:BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(self.data)
    }

    public init(from reader: inout BinaryReader) throws {
        self.data = Data(reader.read(count: UInt32(SolanaPublicKey.Size)))
    }
}

extension SolanaPublicKey {
    public static func newAssociatedToken(pubkey: SolanaPublicKey, mint: SolanaPublicKey) -> SolanaPublicKey? {
        var i = 255
        while i > 0 {
            do {
                var data = Data()
                try pubkey.serialize(to: &data)
                try SolanaPublicKey.TOKENPROGRAMID.serialize(to: &data)
                try mint.serialize(to: &data)
                try UInt8(i).serialize(to: &data)
                try SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID.serialize(to: &data)
                try "ProgramDerivedAddress".serialize(to: &data)
                
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
                try "metadata".serialize(to: &data)
                try SolanaPublicKey.MATEDATAPUBLICKEY.serialize(to: &data)
                try mint.serialize(to: &data)
                try UInt8(i).serialize(to: &data)
                try SolanaPublicKey.MATEDATAPUBLICKEY.serialize(to: &data)
                try "ProgramDerivedAddress".serialize(to: &data)
                
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
                try "ProgramDerivedAddress".serialize(to: &data)
                
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
