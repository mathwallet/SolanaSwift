import XCTest
import BigInt
import CryptoSwift
import BIP39swift
import CTweetNacl
import Base58Swift

@testable import SolanaSwift

final class SolanaSwiftTests: XCTestCase {
    private let mnemonics = "leisure stem trouble conduct exotic biology aerobic fatigue woman negative bomb vicious"
    
    func testKeyPairExample() throws {
        guard let key = try? SolanaKeyPair.randomKeyPair() else {
            debugPrint("error")
            return
        }
        XCTAssertNotNil(key.mnemonics)
        XCTAssertNotNil(key.derivePath)
        XCTAssertNotNil(key.publicKey)
    }
    
    func testTrasaction()  throws {
        let transferInstruction = SolanaInstructionTransfer(
            from: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")! ,
            to:SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!,
            lamports: BigUInt(5000)
        )
        let associatedInstruction = SolanaInstructionAssociatedAccount(
            funding: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
            wallet:  SolanaPublicKey(base58String: "4KxYRXTZ4PXXDCvaQeG75HLJFdKrwVY6bX5nckp8jpHh")!,
            associatedToken: SolanaPublicKey(base58String: "CoPhcr5DrGZx6a3pbB2BmrTHjNAokZScQVUdyqCNWyRR")!,
            mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!
        )
        var transaction = SolanaTransaction()
        transaction.recentBlockhash = SolanaBlockHash(base58String: "9h5dnhmz3vwL25RZ699ZGV7j1NvJ3C2HhPQPcjtDaqcH")!
        transaction.appendInstruction(instruction: transferInstruction)
        transaction.appendInstruction(instruction: associatedInstruction)
        
        debugPrint(transaction.sortedSigners.map({[$0.publicKey.address, $0.isSigner, $0.isWritable]}))
        
        let keypair = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.Ed25519.default)
        let signedTransaction = try transaction.sign(keypair: keypair)
        
        let encodeData = try BorshEncoder().encode(signedTransaction)
        XCTAssertEqual(encodeData.toHexString(), "01f0484c72f2ac1cb0b9e7131761d1aa16005fbc61f3e3d912d5a3ef092b1dcf794f497ff884451cabd2f9242ad1bbfedd0684588118a65ab0867f2ee5edb6760101000609b2d70c003063053412e81ef8386be56719e03425fdce04fc8b6b70a139df139caf52f0d3bb38368a2d7ea17db4bf34393155113a0a3384f9115cc2968c808e20e47c4c5496c9385a7b147c0771976f1b1d78be5f35bfd29aca33260d9e731730316e510e603bf1ce2c4c06aac011a8f299415a91823b27843e471bdf68c0350400000000000000000000000000000000000000000000000000000000000000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f859e867d9845930950c31c76e1573a82de99b91eac9d2ee95eb9b29a722e1db1bd306a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a0000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a98121f7bf81d0a9a955ebf510df653b22672e985c55c69f8e4f2b95e8a398a38602040200020c02000000881300000000000005070001030604080700")
        
        let decodedSignedTransaction = try BorshDecoder.decode(SolanaSignedTransaction.self, from: encodeData)
        debugPrint(decodedSignedTransaction.toHuman())
    }
    
    func testRecoverTransactio222nExamples() throws {
        debugPrint("9U3PefXaFHYiTaCz2p4SsW6X5RK9Kq7FxUeB3PTwpG1a".localizedCompare("9qt6WGCcamzTcAma4mxBgyPyraaWCXuKfdimb3xJ2zC2") == .orderedDescending)
        debugPrint("9U3PefXaFHYiTaCz2p4SsW6X5RK9Kq7FxUeB3PTwpG1a".localizedCompare("9qt6WGCcamzTcAma4mxBgyPyraaWCXuKfdimb3xJ2zC2") == .orderedDescending)
    }
    
    func testRecoverTransactionExamples() throws {
        let encodeDataHex = "01000104e47c4c5496c9385a7b147c0771976f1b1d78be5f35bfd29aca33260d9e731730836325bea4d232c32f9dd2273e84669fbf5388bd78c8ea2d0f42159f132cb49be17cc64f90ee8b99e04a30bb193701b6f6c4a11d8c9f64ea1b6334659e8393ac06ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a9ed9f9fc53adddd5c58cb16ec0ea2d7bba0584669835168d7e85f9c045303e3c0020303010000010903030200000109"
        var decodedTransaction = try BorshDecoder.decode(SolanaTransaction.self, from: Data(hex: encodeDataHex))
        decodedTransaction.feePayer = SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")
        
        debugPrint(decodedTransaction.sortedSigners.map({ [$0.publicKey.address, $0.isSigner, $0.isWritable] }))
        debugPrint(try BorshEncoder().encode(decodedTransaction).toHexString())
        XCTAssertEqual(encodeDataHex, try BorshEncoder().encode(decodedTransaction).toHexString())
    }
    
    
    func testSortSigners()  throws {
        let tempSigners: [SolanaSigner] = [
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: false, isWritable: false),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: true, isWritable: false),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: false, isWritable: true),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!, isSigner: false, isWritable: false),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!, isSigner: true, isWritable: false),
        ]
        
        // 去重
        var uniqueSigners = [SolanaSigner]()
        for s in tempSigners {
            if let i = uniqueSigners.firstIndex(of: s){
                uniqueSigners[i].isSigner = uniqueSigners[i].isSigner || s.isSigner
                uniqueSigners[i].isWritable = uniqueSigners[i].isWritable || s.isWritable
            } else {
                uniqueSigners.append(s)
            }
        }
        
        // 排序
        let signers = uniqueSigners.sorted(by: <)
        
        XCTAssertEqual(signers[0].publicKey.address, "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")
        XCTAssertEqual(signers[1].publicKey.address, "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")
        XCTAssertEqual(signers[2].publicKey.address, "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
    }
    
    func testImportKeyPair() throws {
        let keypair1 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.Ed25519.default)
        XCTAssert(keypair1.publicKey.address == "3w7sqnh3MRpaWHgaxcHekK2eqELC1ugtH2oDbgDcTavb")
        
        let keypair2 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.Ed25519_Old.default)
        XCTAssert(keypair2.publicKey.address == "DcaWQQGErxtzTTph7r5xWMxEvWEywGahtjnRvoJPN9Vz")

        let keypair3 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.BIP32_44.default)
        XCTAssert(keypair3.publicKey.address == "EY2kNS5hKfxxLSkbaBMQtQuHYYbjyYk6Ai2phcGMNgpC")

        let keypair4 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.BIP32_501.default)
        XCTAssert(keypair4.publicKey.address == "C1YfBTFDNujtYxSj6bxtuWSfhBghv1pgRD6Tvyg7kS7")

        let keypair5 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.None.default)
        XCTAssert(keypair5.publicKey.address == "HdTeuiXWF6jXmrBufHqZQQ2WS3Vr15gHVfJdbzr5hKKb")
    }
    
    func testDeriveKeyExample() throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(self.mnemonics) else {
            XCTAssert(false)
            return
        }
        
        let (key, _) = SolanaKeyPair.ed25519DeriveKey(path: "m/44'/501'/0'/0'", seed: mnemonicSeed)
        
        
        let (key1, chainCode1) = SolanaKeyPair.ed25519DeriveKey(path: "m/44'/501'", seed: mnemonicSeed)
        let (key2, _) = SolanaKeyPair.ed25519DeriveKey(path: "0'/0'", key: key1, chainCode: chainCode1)
        
        XCTAssert(key.toHexString() == key2.toHexString())
    }
    
    func testDeriveKeyExample2() throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(self.mnemonics) else {
            XCTAssert(false)
            return
        }
        
        let (key, _) = try SolanaKeyPair.bip32DeriveKey(path: "m/501'/0'/0/0", seed: mnemonicSeed)
        
        
        let (_, node1) = try SolanaKeyPair.bip32DeriveKey(path: "m/501'/0'", seed: mnemonicSeed)
        let (key2, _) = try SolanaKeyPair.bip32DeriveKey(path: "0/0", node: node1)
        
        XCTAssert(key.toHexString() == key2.toHexString())
    }
    
    func testSerializeExample() throws {
        let pubKey1 = SolanaPublicKey.newAssociatedToken(pubkey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!)
        XCTAssertEqual(pubKey1?.address, "Ge1qcAEw2RTXwXnuhnkJHw2cMF3sbwXKFab9F145uAgz")
        
        let pubKey2 = SolanaPublicKey.createProgramAddress(mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!)
        XCTAssertEqual(pubKey2?.address, "45UY8D4hSTskzkLCqyDM3P7iouQyAVB58y4WRaaXCa9p")
        
        let pubKey3 = SolanaPublicKey.createProgramAddress(seeds: Data(hex: "666666"), programId: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!)
        XCTAssertEqual(pubKey3?.address, "3RK5TQt2h13mLrr5Jypzjh39HmBGoe6ybZwXxatskBwr")
    }
    
    func testToHuman() throws {
        let from = SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!
        let to = SolanaPublicKey(base58String: "EY2kNS5hKfxxLSkbaBMQtQuHYYbjyYk6Ai2phcGMNgpC")!
        let lamports = BigUInt(1)
        let instruction = SolanaInstructionTransfer(from: from, to: to, lamports: lamports)
        let dataDic = instruction.toHuman()
        debugPrint(dataDic)
    }
    
    func testVerify() throws {
        let data = "5EUTDDM4RxaskE8QTtnkMEr8KvhK2k1Hif9mLeQnusAaVuVoQz4pVoHgjRfueKU5nfn1ce9a9mjT4iMw2tjtgcMa".base58DecodedData
        let keypair = try SolanaKeyPair(secretKey: Data(data))
        let message = "MathWallet".data(using:.utf8)!
        let signature = try keypair.signDigest(messageDigest: message)
        // 959ba8de3244277188b7c0d3f6921a12afb06ff104c843692eeac43537ab889eff21a71433e559da3b3119a0bd875d8b53c83506ddaa4a76544056581acbe309
        XCTAssertEqual(signature.toHexString(), "959ba8de3244277188b7c0d3f6921a12afb06ff104c843692eeac43537ab889eff21a71433e559da3b3119a0bd875d8b53c83506ddaa4a76544056581acbe309")
        debugPrint(keypair.signVerify(message: message, signature: signature))
    }
    
}
