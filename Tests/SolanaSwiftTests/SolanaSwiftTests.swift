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
    
    func testMetaData() throws {
        let token = SolanaNFTTokenResult(pubkey: "55PCiYAh5aGd32wbFWmt25oJhXGYy85uNECKa76zx3aG", mint: "C5yqbnVsWGbH4WRsrWpnnNgPrAvzfLtMrQN73PuBDsaY", owner: "HjBWJD6jNicWBpkmAqy59ivXbxjRC3XHQKR4Q5G7FAn4", FDAAddress: "4yLoB7AwuiWVhaPFt5dxob2S9CXkVrmcSipphsBP3zsi", amount: 1)
        let provider = SolanaRPCProvider(nodeUrl: "https://solana.maiziqianbao.net")
        let reqeustExpectation = expectation(description: "Tests")
        DispatchQueue.global().async {
            provider.getMetaData(token: token) { metaData in
                print(metaData.data.uri)
                reqeustExpectation.fulfill()
            } failure: { error in
                print(error.localizedDescription)
                reqeustExpectation.fulfill()
            }

        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testVersionedTransaction() throws {
        let data = Data(hex: "8001000812e47c4c5496c9385a7b147c0771976f1b1d78be5f35bfd29aca33260d9e7317301fd46c617a78d58ad3b5f07f56aac435561d1871baaed6823aa59f00fb30adb81fe6f0cf948fdbfc2684fa31f99ff65fc32a0649394ca66de344bd86ce4c3cdd33a6027081c1e80836ff22e525fa6b1d29a1596604d2b59d5ae81c198bb7227334095ec686a1ace53c70e6daee8aeb6cbe5e17c8cd300f2718b80ac86c9c029f38aa095869b344ecb3c4700ae48cfa191a38fdd811728d6809e04325afd93ee83ffc3a2c388976abb424dd6e9f207dbb4ad2376386c3d781a5356ab4b7af088d5d2b063a064e144f91b674b9781d9a7ebb1ea8cf3e37567d2802eeac7c33466c676b3df0361794418b038738ecfaa51f7b7f32bdd23b26cb058504046ccb1e30c9317918e86000bca6fc7f1d0b1a1897f0e3814bf6e7486e8b00cc995a6b180000000000000000000000000000000000000000000000000000000000000000000306466fe5211732ffecadba72c39be7bc8ce5bbc5f7126b2c439b3a400000000479d55bf231c06eee74c56ece681507fdb1b2dea3f48e5102b1cda256bc138f06ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a920b5e7b3f8fe3d8936a37ce01660130a00a7c3a89975278587fa6f61cbb0a3188c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f859b43ffa27f5d7f64a74c09b1f295879de4b09ab36dfc9dd514b321aa7b38ce5e8ce010e60afedb22717bd63192f54145a3f965a33bb82d2c7029eb2ce1e2082641de90a68a46df33b5ba88cbeb9d01c9831d360fed1246822fbd87dd6456e46a7050b00050207e707000b000903d9960000000000000f060008001d0a0d01010c310d0e0003020108111d0c0c100c24250d260e02051c1a1b2220210e0504191817160d2323151e0d0e14011204130706091f2dc1209b3341d69c810d030000000a64000109640102110064020352140200000000007c251300000000003200000d0308000001090378566ccc5be24d6ad5d525cf77c8f5222f0c199063bfcfffc8ceb9fabe0a6bdf03111315031c1918e981bf8eefb6ff3425592659ab35729b34987f3008500439cd98ca7af239ac6a0509080b0c0d04070e0f0ab21d5a886407a519ce0ff9031bbc446a8378afa22c3d6373f2f540c27da5a63e03282c2a03292d2e")
        var binaryReader = BinaryReader(bytes: data.bytes)
        let tx = try SolanaVersionedTransaction.init(from: &binaryReader)
        debugPrint(tx.version)
        debugPrint(tx.toHuman())
        
        var data2 = Data()
        try tx.serialize(to: &data2)
        XCTAssertTrue(data2 == data)
    }
    
    func testSignedVersionedTransaction() throws {
        let data = Data(hex: "010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000f1be47c4c5496c9385a7b147c0771976f1b1d78be5f35bfd29aca33260d9e7317301ae7497a29fa938322c6d7b7b111f9dd2b59a625395c403376b9a7d01e8971042aabf221b662c7e7e944649b07f7c9f6a970f18ad748c23b589c4a3b562203123535f3d2822c16a137687b6f74f004237beae64eb6996e72b6f98fe4302992b433a6027081c1e80836ff22e525fa6b1d29a1596604d2b59d5ae81c198bb722735ae634efc34d60c59e40470c951be7fd8edd9828e16941f7959ca8b5bf7896e15cbb4afaaa5f56b1d4fb73c154432bbda4d4f19536974420b2b7b86156f030cf676b3df0361794418b038738ecfaa51f7b7f32bdd23b26cb058504046ccb1e30c8d520401ee1f11b3a2fbd49bcdcb215c0555a289d3a0b028ce523a3caf79b7be10c3619b8bd3d1a4083cf8eb392ff002854b3c192cb8cfc3964e40e103d2cbde4027701cc13227a70889a4d75954a964f8b1dd74e7cd26cb8b1a53f7a5280f7f16385d76168258db469fb3f09c85d3eab932e3737c3c1eebf3ee9ea57b482a800000000000000000000000000000000000000000000000000000000000000008aef7df7e3a674a43ed18156220e0306fa47878b93207e2495e59eedbbda4ca18c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8590306466fe5211732ffecadba72c39be7bc8ce5bbc5f7126b2c439b3a40000000b43ffa27f5d7f64a74c09b1f295879de4b09ab36dfc9dd514b321aa7b38ce5e8b5852f26dd2467dd4060ef04671d8dbefea7f5888573c4f92220c884a5ad09b8ce010e60afedb22717bd63192f54145a3f965a33bb82d2c7029eb2ce1e208264d2d9621d9e185e06db119c65505d576548b27b6dc6a899b0c29e73d10667d630e7ea8d1030c0a665a02a411f480ae23aed072cf8c607d1fe750de76cb05f1883f188505e87a48bd9d99ec11ce618a8ccf4b5b6bae1325cb329e9c543368ed01d0479d55bf231c06eee74c56ece681507fdb1b2dea3f48e5102b1cda256bc138f052a42bec2fddc6579cc6e752049cd55512cf97e0972e2ed617f74257a322670052eca368763a5955f62734e40e772978388ec2bd8f50c6bf223f22d247b42ae069b8857feab8184fb687f634618c035dac439dc1aeb3b5598a0f0000000000106ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a9f7d133f47718412993d8a172e363e2215a929fe52dac315b8c3c7365b51aa4c8050f0005027c1b05000f00090368e90000000000000e06000700190c1a010116211a1500040201071219161610160d131105030b061509021a18171a14150901080a29c1209b3341d69c8108020000000f006400010a640102290a010000000000178b0900000000003200001a030700000109")
        guard let signedTx = try? BorshDecoder.decode(SolanaSignedVersionedTransaction.self, from: data) else {
            XCTAssert(false, "Invalid Signed VersionedTransaction")
            return
        }
        debugPrint(signedTx.transaction.toHuman())
        
        var data2 = Data()
        try signedTx.serialize(to: &data2)
        XCTAssertTrue(data2 == data)
    }
    
    func testCreateVersionedTransaction() throws {
        // Legacy
        var transaction = SolanaTransaction()
        transaction.appendInstructions(instructions: [
            SolanaInstructionTransfer(
                from: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")! ,
                to:SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!,
                lamports: BigUInt(5000)
            ),
            SolanaInstructionAssociatedAccount(
                funding: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
                wallet:  SolanaPublicKey(base58String: "4KxYRXTZ4PXXDCvaQeG75HLJFdKrwVY6bX5nckp8jpHh")!,
                associatedToken: SolanaPublicKey(base58String: "CoPhcr5DrGZx6a3pbB2BmrTHjNAokZScQVUdyqCNWyRR")!,
                mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!
            ),
            SolanaInstructionAssetOwner(
                destination: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
                owner: .SYSTEM_PROGRAM_ID
            )
        ])
        debugPrint(try BorshEncoder().encode(transaction).toHexString())
        
        // New
        let newMessage = try SolanaMessageLegacy([
            SolanaProgramSystem.transfer(
                from: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
                to: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!,
                lamports: 5000
            ),
            SolanaProgramAssociatedTokenAccount.create(
                funder: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
                associatedToken: SolanaPublicKey(base58String: "CoPhcr5DrGZx6a3pbB2BmrTHjNAokZScQVUdyqCNWyRR")!,
                owner: SolanaPublicKey(base58String: "4KxYRXTZ4PXXDCvaQeG75HLJFdKrwVY6bX5nckp8jpHh")!,
                mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!
            ),
            SolanaProgramOwnerValidation.createOwnerValidation(
                account: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
                programId: .SYSTEM_PROGRAM_ID
            )
        ])
        debugPrint(try BorshEncoder().encode(newMessage).toHexString())
    }
}
