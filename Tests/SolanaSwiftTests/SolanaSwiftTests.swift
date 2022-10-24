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
    
    func testRecoverTransactionExamples() throws {
        let encodeDataHex = "02000816e47c4c5496c9385a7b147c0771976f1b1d78be5f35bfd29aca33260d9e731730634b1dbffe68fe9f445f72f49acc1ecf701720d3ce93d9e05050a80a11e8cf3b290bebb87d739e0289137b3ac11fc1d73900f0a29ac5b666605b651d1f3fa8912fbdfb8a1ee2ae7ba28b933665fbe78ee6ade8d499e13a711835611a59a9530a30be5c1c165342a8e829872e15d06ed9d2f301edf7edb74701c17556bcd986cc3493d66ada9112030e98bbc28661b192b766285a21d9f071598e40781615aff545b8acd356d71db052d102c6cdcf4b98c92356a9cd9d8e9060ebe4f9ccf9d4bd50ecda7dce0436fea5b6ec7fe89a75ab6985baa3cec99f460a118aef15256d8b513b4c3991d17c49970f5375cd5799a69ebc8d9d99e683f40476aa3cb627196e8d1e25199fe682f7fc8b5631845efe08c64810adca10de6641ca28dabe4a22159f08328ebbbc694f3a04df30520012efe19b59e555c0068db3fb746207b44802a3a3b3e889585b68ae70e1bc3768d5744d8f6437b55f03952c849292553ef538a4f30af8ac99615556b1525c94f8828536a0415c948e3594be5588925213bad1cc74199b45bacf982d365e46bfef6a11a17a9dc7531e172a67e24ae66f71ad3800000000000000000000000000000000000000000000000000000000000000004157b0580f31c5fce44a62582dbcf9d78ee75943a084a393b350368d228993084bd949c43602c33f207790ed16a3524ca1b9975cf121a2a90cffec7df8b68acd5fb728afdcdc047878ee843a6feb44af28cd53a34828d9903b5ad5e69719552a850f2d6e02a47af824d09ab69dc42d70cb28cbfa249fb7ee57b9d256c12762ef069b8857feab8184fb687f634618c035dac439dc1aeb3b5598a0f0000000000106a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a0000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a95528deacd3244ed96f25e16e3a0bd37a30ada2dabc18b874763acc202dd29eed040e020001340000000070b4b70000000000a50000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a91504011300140101101215090f07060d02120c0b0304080511010a0011098096980000000000b6d408000000000015030100000109"
        let decodedTransaction = try BorshDecoder.decode(SolanaTransaction.self, from: Data(hex: encodeDataHex))
        
        debugPrint(decodedTransaction.sortedSigners.map({ [$0.publicKey.address, $0.isSigner, $0.isWritable] }))
        debugPrint(try BorshEncoder().encode(decodedTransaction).toHexString())
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
