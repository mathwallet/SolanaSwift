//
//  SolanaKeyPair.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import CryptoSwift
import TweetNacl
import BigInt
import BIP39swift
import BIP32Swift

public struct SolanaKeyPair {

    public var mnemonics: String?
    public var derivePath: String?
    
    public var secretKey: Data
    public var publicKey: SolanaPublicKey

    public init(secretKey: Data) throws {
        self.secretKey = secretKey
        let pubKey = try NaclSign.KeyPair.keyPair(fromSecretKey: secretKey).publicKey
        self.publicKey = SolanaPublicKey(data: pubKey)
    }
    
    public init(seed: Data) throws {
        let secretKey = try NaclSign.KeyPair.keyPair(fromSeed: seed[0..<32]).secretKey
        try self.init(secretKey: secretKey)
    }
    
    public init(mnemonics: String, path: String) throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw Error.invalidMnemonic
        }
        
        let pathType = SolanaMnemonicPath.getType(mnemonicPath: path)
        
        switch pathType {
        case .Ed25519, .Ed25519_Old:
            let (seed, _) = SolanaKeyPair.ed25519DeriveKey(path: path, seed: mnemonicSeed)
            try self.init(seed: seed)
        case .BIP32_44, .BIP32_501:
            let (seed, _) = try SolanaKeyPair.bip32DeriveKey(path: path, seed: mnemonicSeed)
            try self.init(seed: seed)
        default:
            try self.init(seed: mnemonicSeed)
        }
        
        self.mnemonics = mnemonics
        self.derivePath = path
    }
    
    public static func randomKeyPair() throws -> SolanaKeyPair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw SolanaKeyPair.Error.invalidMnemonic
        }
        return try SolanaKeyPair(mnemonics: mnemonic, path: SolanaMnemonicPath.PathType.Ed25519.default)
    }
    
    public static func ed25519DeriveKey(path: String, seed: Data) -> (key: Data, chainCode: Data) {
        return NaclSign.KeyPair.deriveKey(path: path, seed: seed)
    }
    
    public static func ed25519DeriveKey(path: String, key: Data, chainCode: Data) -> (key: Data, chainCode: Data) {
        return NaclSign.KeyPair.deriveKey(path: path, key: key, chainCode: chainCode)
    }
    
    public static func bip32DeriveKey(path: String, seed: Data) throws -> (key: Data, HDNode) {
        guard let node = HDNode(seed: seed) else {
            throw Error.invalidDerivePath
        }
        
        return try self.bip32DeriveKey(path: path, node: node)
    }
    
    public static func bip32DeriveKey(path: String, node: HDNode) throws -> (key: Data, HDNode) {
        guard let treeNode = node.derive(path: path) else {
            throw Error.invalidDerivePath
        }
        
        guard let key = treeNode.privateKey else {
            throw Error.invalidDerivePath
        }
        return (key, treeNode)
    }
}

// MARK: - Sign&Verify

extension SolanaKeyPair {
    public func signDigest(messageDigest:Data) throws -> Data {
        return try NaclSign.signDetached(message: messageDigest, secretKey: secretKey)
    }
    
    public func signVerify(message: Data, signature: Data) -> Bool {
        guard let ret = try? NaclSign.signDetachedVerify(message: message, sig: signature, publicKey: publicKey.data) else {
            return false
        }
        return ret
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
