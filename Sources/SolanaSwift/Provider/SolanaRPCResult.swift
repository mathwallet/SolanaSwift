//
//  SolanaRPCResult.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/31.
//

import Foundation
import AnyCodable

public struct SolanaSolanaTokenAccountTokenAmount:Codable {
    public var amount:String?
    public var uiAmount:Double?
    public var decimals:Int?
    public var uiAmountString:String
}


public struct SolanaSolanaTokenAccountinfo:Codable {
    public var accountType:String?
    public var tokenAmount:SolanaSolanaTokenAccountTokenAmount?
    public var isInitialized:Bool?
    public var isNative:Bool?
    public var mint:String?
    public var owner:String?
}

public struct SolanaSolanaTokenAccountsparsed:Codable {
    public var type:String?
    public var info:SolanaSolanaTokenAccountinfo?
}

public struct SolanaSolanaTokenAccountsData:Codable {
    public var program:String?
    public var parsed:SolanaSolanaTokenAccountsparsed?
}

public struct SolanaSolanaTokenAccount:Codable {
    public var data:SolanaSolanaTokenAccountsData?
    public var executable:Bool?
    public var lamports:Int64?
    public var owner:String?
}

public struct SolanaTokenAccountsByOwnerValue:Codable {
    public var account:SolanaSolanaTokenAccount?
    public var pubkey:String?
    public var symbol:String?
}

public struct SolanaTokenAccountsByOwner:Codable {
    public var value:[SolanaTokenAccountsByOwnerValue]?
}

public struct SolanaTokenSupply: Codable {
    public var amount: String
    public var decimals: Int
}

public struct SolanaTokenSupplyResult: Codable {
    public var value: SolanaTokenSupply
}

public struct SolanaNodeStatusResult: Codable {
    public var absoluteSlot:Int64?
    public var blockHeight:Int64?
    public var epoch:Int64?
    public var slotIndex:Int64?
    public var slotsInEpoch:Int64?
    public var transactionCount:Int64?
}

public struct SolanaFeeCalculator:Codable {
    public var lamportsPerSignature:Int64?
}


public struct SolanaRecentBlockhashValue: Codable {
    public var blockhash:String?
    public var feeCalculator:SolanaFeeCalculator?
    public var lastValidBlockHeight:UInt64?
    public var lastValidSlot:UInt64?
}

public struct SolanaRecentBlockhashResult: Codable {
    public var value:SolanaRecentBlockhashValue?
}

public struct SolanaAccountValueResult: Codable {
    public var lamports:Int64?
    public var executable:Bool?
    public var owner:String?
    public var data:[String]?
}

public struct SolanaJsonRpcAccountResult: Codable {
    public var value:SolanaAccountValueResult?
}

public struct SolanaBlanceValue: Codable {
    public var value:Int64?
}

public struct SolanaJsonRpcError: Codable {
    public var code:Int?
    public var message:String?
}

public struct SolanaNFTTokenResult {
    public var pubkey:String
    public var mint:String
    public var owner:String
    public var FDAAddress:String
    public var amount:Int
}

public struct SolanaNFTResult: Codable {
    public var _id:String?
    public var image:String?
    public var description:String?
    public var name:String?
    public var mint:String?
    public var symbol:String?
}

public struct SolanaTokenFilterResult: Codable {
    public var data: SolanaTokenFilterDataResult?
    public var message: String?
    public var code: Int?
}

public struct SolanaTokenFilterDataResult: Codable {
    public var collectibles: [SolanaTokenCollectibleResult]?
    public var isTrimmed: Bool?
}

public struct SolanaTokenCollectibleResult: Codable {
    public var id: String?
    public var chain: AnyCodable?
    public var name: String?
    public var symbol: String?
    public var collection: SolanaTokenCollectionResult?
    public var media: AnyCodable?
    public var attributes: [AnyCodable]?
    public var balance: String?
    public var decimals: String?
    public var owner: String?
    public var chainData: SolanaTokenChainDataResult?
    public var tokenCount: Int?
}

public struct SolanaTokenCollectionResult: Codable {
    public var id: String?
    public var isValidCollectionId: Bool?
    public var imageUrl: String?
    public var isSpam: Bool?
    public var spamStatus: String?
    public var ownerCount: Int?
    public var totalCount: Int?
    public var tokenCount: Int?
    public var marketplaces: [AnyCodable]?
}

public struct SolanaTokenChainDataResult: Codable {
    public var balance: String?
    public var decimals: String?
    public var mint: String?
    public var tokenAccount: String?
    public var standard: String?
    public var isFrozen: Bool?
    public var programId: String?
    public var mintExtensions: [AnyCodable]?
}
