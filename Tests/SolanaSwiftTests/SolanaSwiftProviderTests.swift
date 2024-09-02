//
//  SolanaSwiftProviderTests.swift
//  
//
//  Created by mathwallet on 2024/8/26.
//

import XCTest
@testable import SolanaSwift

final class SolanaSwiftProviderTests: XCTestCase {
    
    let provider = SolanaRPCProvider(url: URL(string:  "https://api.mainnet-beta.solana.com")!)
    
    
    func testGetBlockHeightExamples() async throws {
        let blockHeight = try await provider.getBlockHeight()
        debugPrint("getBlockHeight", blockHeight)
    }
    
    func testGetTokenAccountInfoExamples() async throws {
        let owner = SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!
        let accountInfo = try await provider.getAccountInfo(account: owner, opts: [.encoding(.base58)])
        debugPrint("getAccountInfo", accountInfo ?? "accountInfo nil")
    }
    
    func testGetTokenAccountsByOwnerExamples() async throws {
        let tokenAccountsByOwner = try await provider.getTokenAccountsByOwner(
            account: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!,
            mint: SolanaPublicKey(base58String: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")!
        )
        debugPrint("getTokenAccountsByOwner", tokenAccountsByOwner)
        
        let tokenAccountsByOwner2 = try await provider.getTokenAccountsByOwner(
            account: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!,
            programId: SolanaPublicKey.TOKEN_PROGRAM_ID
        )
        debugPrint("getTokenAccountsByOwner2", tokenAccountsByOwner2)
    }
    
    func testGetBalanceExamples() async throws {
        let balance = try await provider.getBalance(
            account: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!
        )
        debugPrint("getBalance", balance)
    }
    
    func testGetFeeForMessageExamples() async throws {
        let latestBlockhash = try await provider.getLatestBlockhash()
        debugPrint("getLatestBlockhash", latestBlockhash)

        var newMessage = try SolanaMessageLegacy([
            SolanaProgramSystem.transfer(
                from: SolanaPublicKey(base58String: "GNutLCXQEEcmxkJH5f5rw51bTW2QcLGXqitmN3EaVPoV")!,
                to: SolanaPublicKey(base58String: "D37m1SKWnyY4fmhEntD84uZpjejUZkbHQUBEP3X74LuH")!,
                lamports: 1000
            )
        ])

        newMessage.recentBlockhash = SolanaBlockHash(base58String: latestBlockhash.blockhash)!
        let fee = try await provider.getFeeForMessage(message: newMessage)
        debugPrint("getFeeForMessage: \(fee ?? 0)")
    }
    
    func testTokenSupplyData() async throws {
        let mint = SolanaPublicKey(base58String: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB")!
        let supply = try await provider.getTokenSupply(mint: mint)
        debugPrint(supply)
    }
    
    func testMetaData() async throws {
        let token = SolanaNFTTokenResult(
            pubkey: SolanaPublicKey(base58String: "55PCiYAh5aGd32wbFWmt25oJhXGYy85uNECKa76zx3aG")!,
            mint: SolanaPublicKey(base58String: "C5yqbnVsWGbH4WRsrWpnnNgPrAvzfLtMrQN73PuBDsaY")!,
            owner: SolanaPublicKey(base58String: "HjBWJD6jNicWBpkmAqy59ivXbxjRC3XHQKR4Q5G7FAn4")!,
            FDAAddress: SolanaPublicKey(base58String: "4yLoB7AwuiWVhaPFt5dxob2S9CXkVrmcSipphsBP3zsi")!,
            amount: 1
        )
        let metaData = try await provider.getMetaData(token: token)
        debugPrint(metaData)
    }
    
    func testNftTokenfData() async throws {
        let owner = SolanaPublicKey(base58String: "ApJ48xWtb3qmppDMGwvRxdnf4utH2rYoW6pFyd8Ynzud")!
        let programId = SolanaPublicKey.TOKEN_PROGRAM_ID
        let uri = "https://a5.maiziqianbao.net/api/v1/collectibles/phantom_collectibles_v1"
        let nftTokenResult = try await provider.getNFTTokensByOwner(owner: owner, programId: programId, filterUrl: uri)
        debugPrint(nftTokenResult)
    }

}
