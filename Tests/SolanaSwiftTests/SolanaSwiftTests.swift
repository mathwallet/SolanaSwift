import XCTest
import BigInt
import CryptoSwift
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
        let assin = SolanaInstructionAssociatedAccount(from: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!, to:  SolanaPublicKey(base58String: "4KxYRXTZ4PXXDCvaQeG75HLJFdKrwVY6bX5nckp8jpHh")!, associatedToken: SolanaPublicKey(base58String: "CoPhcr5DrGZx6a3pbB2BmrTHjNAokZScQVUdyqCNWyRR")!, mint: SolanaPublicKey(base58String: "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza")!)
        var transaction = SolanaTransaction()
        transaction.appendInstruction(instruction: instru)
        transaction.appendInstruction(instruction: assin)
        let keypair = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPathType.SolanaMnemonicPathType_Ed25519.path())
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
        let keypair1 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPathType.SolanaMnemonicPathType_Ed25519.path())
        XCTAssert(keypair1.publicKey.address == "3w7sqnh3MRpaWHgaxcHekK2eqELC1ugtH2oDbgDcTavb")
        
        let keypair2 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPathType.SolanaMnemonicPathType_Ed25519_Old.path())
        XCTAssert(keypair2.publicKey.address == "DcaWQQGErxtzTTph7r5xWMxEvWEywGahtjnRvoJPN9Vz")
//
        let keypair3 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPathType.SolanaMnemonicPathType44.path())
        XCTAssert(keypair3.publicKey.address == "EY2kNS5hKfxxLSkbaBMQtQuHYYbjyYk6Ai2phcGMNgpC")
//
        let keypair4 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPathType.SolanaMnemonicPathType501.path())
        XCTAssert(keypair4.publicKey.address == "C1YfBTFDNujtYxSj6bxtuWSfhBghv1pgRD6Tvyg7kS7")

        let keypair5 = try SolanaKeyPair(mnemonics: self.mnemonics, path: SolanaMnemonicPathType.SolanaMnemonicPathTypNone.path())
        XCTAssert(keypair5.publicKey.address == "HdTeuiXWF6jXmrBufHqZQQ2WS3Vr15gHVfJdbzr5hKKb")
        
    }
}
