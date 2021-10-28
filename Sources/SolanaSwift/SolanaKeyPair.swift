//
//  SolanaKeyPair.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import CryptoSwift
import Ed25519
import BigInt
import BIP39swift
import BIP32Swift


public struct SolanaKeyPair {
    public static let deriveKeyString = "ed25519 seed"
    
    public var secretKey: Data
    public var mnemonics: String?
    public var derivePath: String?
    
    public var publicKey: SolanaPublicKey {
        return SolanaPublicKey(data: secretKey.subdata(in:32..<64))
    }

    public init(secretKey: Data) {
        self.secretKey = secretKey
    }
    
    public init(seed: Data) throws {
        let ed25519KeyPair = try Ed25519KeyPair(seed: Ed25519Seed(raw: seed[0..<32]))
        var secretKeyData = Data(ed25519KeyPair.privateRaw)
        secretKeyData.append(ed25519KeyPair.publicKey.raw)
        
        self.secretKey = secretKeyData
    }
    
    public init(seed: Data? = nil,mnemonics: String, path:String) throws {
        if seed == nil {
            try self.init(mnemonics: mnemonics, path: path)
        } else {
            try self.init(seed:seed!)
            self.mnemonics = mnemonics
            self.derivePath = path
        }
    }
    
    public init(mnemonics: String, path:String = "") throws {
        let pathType = SolanaMnemonicPath.getMnemonicPathType(mnemonicPath: path)
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw Error.invalidMnemonic
        }
        switch pathType {
        case .SolanaMnemonicPathType_Ed25519,.SolanaMnemonicPathType_Ed25519_Old:
            let (deSeed,_) = SolanaKeyPair.deriveKey(path:path , seed: mnemonicSeed, keyString: SolanaKeyPair.deriveKeyString)
            try self.init(seed:deSeed,mnemonics: mnemonics,path: path)
        case .SolanaMnemonicPathType44,.SolanaMnemonicPathType501:
            guard let node = HDNode(seed: mnemonicSeed), let treeNode = node.derive(path: path) else {
                throw Error.invalidDerivePath
            }
            guard let nodeSeed = treeNode.privateKey else {
                throw Error.invalidDerivePath
            }
            try self.init(seed:nodeSeed,mnemonics: mnemonics,path: path)
        default:
            try self.init(seed:mnemonicSeed,mnemonics: mnemonics,path: path)        }
    }
    
    public static func randomKeyPair() throws -> SolanaKeyPair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw SolanaKeyPair.Error.invalidMnemonic
        }
        return try SolanaKeyPair(mnemonics: mnemonic, path:SolanaMnemonicPathType.SolanaMnemonicPathType_Ed25519.path())
    }
    
    public static func deriveKey(path:String, seed:Data, keyString:String) -> (seed:Data,chainCode:Data) {
        let (masterKey,masterChainCode) = self.masterKeys(seed: seed, keyString: keyString)
        let paths = path.components(separatedBy: "/")
        return self.deriveKeys(paths: paths, seed: masterKey, chainCode: masterChainCode)
    }
    
    public static func masterKeys(seed:Data, keyString:String) -> (seedData:Data,chainCode:Data) {
        let hashData = Data(try! HMAC(key:[UInt8](keyString.utf8), variant: .sha512).authenticate([UInt8](seed)))
        let masterKey = hashData.subdata(in:0..<32)
        let masterChainCode = hashData.subdata(in:32..<64)
        return (masterKey,masterChainCode)
    }
    
    public static func deriveKeys(paths:[String], seed:Data,chainCode:Data) -> (seed:Data,chainCode:Data) {
        var seedData = seed
        var chainCodeData = chainCode
        for path in paths {
            if path == "m" {
                continue
            }
            var hpath:UInt32 = 0
            if path.contains("'") {
                let pathnum = UInt32(path.replacingOccurrences(of: "'", with: "")) ?? 0
                hpath = pathnum + 0x80000000
            } else {
                hpath = UInt32(path) ?? 0
            }
            let pathData32 = UInt32(hpath)
            let pathDataBE = withUnsafeBytes(of: pathData32.bigEndian, Array.init)
            var data = Data()
            data.append([0], count: 1)
            data.append(seedData)
            data.append(pathDataBE,count: 4)
            let d = Data(try! HMAC(key: chainCodeData.bytes,variant: .sha512).authenticate(data.bytes))
            seedData = d.subdata(in: 0..<32)
            chainCodeData = d.subdata(in:32..<64)
        }
        return (seedData,chainCodeData)
    }
}

// MARK: - Sign

extension SolanaKeyPair {
    public func signDigest(messageDigest:Data) -> Data {
        return try! Ed25519KeyPair(raw:self.secretKey).sign(message: messageDigest).raw
    }
}


// MARK: Error

extension SolanaKeyPair {
    public enum Error: String, LocalizedError {
        case invalidMnemonic
        case invalidDerivePath
        case unknown
        
        public var errorDescription: String? {
            return "SolanaKeyPair.Error.\(rawValue)"
        }
    }
}
