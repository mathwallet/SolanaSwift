//
//  SolanaRPCResult.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/31.
//

import Foundation


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
    public var lamports:Int32?
    public var owner:String?
    public var rentEpoch:Int?
}

public struct SolanaTokenAccountsByOwnerValue:Codable {
    public var account:SolanaSolanaTokenAccount?
    public var pubkey:String?
    public var symbol:String?
}

public struct SolanaTokenAccountsByOwner:Codable {
    public var value:[SolanaTokenAccountsByOwnerValue]?
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
    public var rentEpoch:Int64?
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
    var pubkey:String
    var mint:String
    var owner:String
    var FDAAddress:String
    var amount:Int
}

public struct SolanaNFTItemResult:Codable {
    var _id:String?
    var image:String?
    var description:String?
    var name:String?
}
