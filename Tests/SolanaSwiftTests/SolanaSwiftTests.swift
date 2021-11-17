import XCTest
import BigInt
import CryptoSwift
import BIP39swift

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
    
    func testDataExample() throws {
        var data =  Data()
        data.appendUInt8(1)
        XCTAssertTrue(data.toHexString() == "01")
        
        var data1 =  Data()
        data1.appendUInt16(1)
        XCTAssertTrue(data1.toHexString() == "0100")
        
        var data2 =  Data()
        data2.appendUInt32(1)
        XCTAssertTrue(data2.toHexString() == "01000000")
        
        var data3 =  Data()
        data3.appendUInt64(1)
        XCTAssertTrue(data3.toHexString() == "0100000000000000")
    }
    
    func testDataAdvanceExample() throws {
        var data =  Data()
        data.appendVarInt(1291)
        debugPrint(data.toHexString())
    }
    
    func testTrasaction()  throws {
        let instru = SolanaInstructionTransfer(from: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")! , to:SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!, lamports: BigUInt(5000))
        
        debugPrint(instru.promgramId.address)
        debugPrint(instru.signers)
        debugPrint(instru.data.toHexString())
        debugPrint(instru.toHuman())
        
        let assin = SolanaInstructionAssociatedAccount(from: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, to:  SolanaPublicKey(base58String: "4KxYRXTZ4PXXDCvaQeG75HLJFdKrwVY6bX5nckp8jpHh")!, associatedToken: SolanaPublicKey(base58String: "CoPhcr5DrGZx6a3pbB2BmrTHjNAokZScQVUdyqCNWyRR")!, mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!)
        var transaction = SolanaTransaction()
        transaction.appendInstruction(instruction: instru)
        transaction.appendInstruction(instruction: assin)
        
        let keypair = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPath.PathType.Ed25519.default)
        transaction.sign(keypair: keypair)
        debugPrint(transaction.serizlize().toHexString())
    }
    
    
    func testSortSigners()  throws {
        var tempSigners:[SolanaSigner] = [
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: false, isWritable: false),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: true, isWritable: false),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!, isSigner: true, isWritable: true),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!, isSigner: false, isWritable: false),
            SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, isSigner: false, isWritable: true),
        ]
        // 排序
        tempSigners = tempSigners.sorted(by: >)
        
        debugPrint(tempSigners)
        
        // 去重
        var signers = [SolanaSigner]()
        for signer in tempSigners {
            if !signers.contains(signer) {
                signers.append(signer)
            }
        }

        debugPrint(signers)
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
    
    func testDecodeExample() throws {
        var data = Data()
        data.appendUInt8(10)
        data.appendUInt16(10)
        data.appendUInt32(120)
        data.appendUInt64(10)
        data.appendVarInt(288)
        data.appendUInt8(1)
        
        debugPrint(data.toHexString())
        
        let data2 = Data(hex: "0a0a00780000000a00000000000000a00201")
        var index = 0
        debugPrint(data2.readUInt8(at: index))
        index = index + 1
        
        debugPrint(data2.readUInt16(at: index))
        index = index + 2
        
        debugPrint(data2.readUInt32(at: index))
        index = index + 4
        
        debugPrint(data2.readUInt64(at: index))
        index = index + 8
        
        var length: Int = 0
        debugPrint(data2.readVarInt(at: index, length: &length))
        index = index + length
        
        debugPrint(data2.readUInt8(at: index))
        
        
        
    }
    func testToHuman() throws {
        let array:[SolanaSigner] = [SolanaSigner(publicKey: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,isSigner: true,isWritable: true),SolanaSigner(publicKey: SolanaPublicKey(base58String: "EY2kNS5hKfxxLSkbaBMQtQuHYYbjyYk6Ai2phcGMNgpC")!,isSigner: false,isWritable: true),SolanaSigner(publicKey: SolanaPublicKey(base58String: "DcaWQQGErxtzTTph7r5xWMxEvWEywGahtjnRvoJPN9Vz")!)]
        let instruction = SolanaInstructionTransfer(promgramId: SolanaPublicKey(base58String: "TokenwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!, signers: array, data: Data(hex: "0x02000000a08601000000000002000000a086010000000000"))
        
        let dataDic:Dictionary = instruction!.toHuman()
        let dataarray = dataDic["data"] as! Dictionary<String, Any>
        let data = try? JSONSerialization.data(withJSONObject: dataarray, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        debugPrint(str!)
    }
    
    func testDeserialize() throws {
        let data = Data(hex: "0x048716c15d84eba15ea152ac8f09ac052f66ffb6ade834e1afb6ea91dd347e0a25cebf0e4cdae0a37c34121843f5a759b2be06be7ca7eac23b6b18700e38717c90200000004f70616c204a65740000000000000000000000000000000000000000000000000a0000004f50414c4a0000000000c800000068747470733a2f2f67616c6178792e7374617261746c61732e636f6d2f6e6674732f45763378556863314c657169347152324535566f4739706378437648486d6e416153525650673438357841540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
//        let dataup = SolanaPublicKey(base58String: "Ev3xUhc1Leqi4qR2E5VoG9pcxCvHHmnAaSRVPg485xAT")!
        
        let ddd = try! BorshDecoder().decode(MetaPlexMeta.self, from: data)
//        debugPrint(dataup.data.toHexString())
    }
}
