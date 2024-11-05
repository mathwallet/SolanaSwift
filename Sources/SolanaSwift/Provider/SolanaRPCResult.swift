//
//  SolanaRPCResult.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/31.
//

import Foundation
import AnyCodable

public enum SolanaRpcProviderError: LocalizedError {
    case unknown
    case server(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .server(let message):
            return message
        default:
            return "Unknown error"
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .server(let message):
            return message
        default:
            return "Unknown error"
        }
    }
}

public struct SolanaRpcResult<T: Decodable>: Decodable {
    public var jsonrpc: String?
    public var id: Int
    public var result: T?
    public var error: SolanaRPCError?
}

public struct SolanaRPCError: Decodable {
    public var code: Int
    public var message: String
}

public enum SolanaRPCCommitment: String {
    case finalized
    case confirmed
    case processed
}

public enum SolanaRPCEncoding : String {
    case base58
    case base64
    case base64_zstd = "base64+zstd"
    case jsonParsed
}

public enum SolanaRPCOptional {
    case commitment(_ commitment: SolanaRPCCommitment)
    case encoding(_ encoding: SolanaRPCEncoding)
    case minContextSlot(_  minContextSlot: UInt64)
    
    public var key: String {
        switch self {
        case .commitment:
            return "commitment"
        case .encoding:
            return "encoding"
        case .minContextSlot:
            return "minContextSlot"
        }
    }
    
    public var value: Any {
        switch self {
        case .commitment(let commitment):
            return commitment.rawValue
        case .encoding(let encoding):
            return encoding.rawValue
        case .minContextSlot(let minContextSlot):
            return minContextSlot
        }
    }
    
    public static func getParameters(_ opts: [SolanaRPCOptional]?) -> [String: Any]? {
        guard let _opts = opts, _opts.count > 0 else { return nil }
        
        var parameters: [String: Any] = [:]
        for opt in _opts {
            parameters[opt.key] = opt.value
        }
        return parameters
    }
}

public struct SolanaRPCAccountInfo: Decodable {
    public var lamports: UInt64
    public var executable: Bool
    public var owner: SolanaPublicKey
    public var data: AnyCodable
}

public struct SolanaSignaturesForAddressResult: Decodable {
    public var err: AnyCodable?
    public var memo: AnyCodable?
    public var confirmationStatus: String
    public var signature: String
    public var slot: UInt64
    public var blockTime: UInt64
}

public struct SolanaRPCAccountInfoResult: Decodable {
    public var value: SolanaRPCAccountInfo?
}

public struct SolanaRPCTokenAccountTokenAmount: Decodable {
    public var amount: String
    public var decimals:Int
}


public struct SolanaRPCTokenAccountinfo: Decodable {
    public var tokenAmount: SolanaRPCTokenAccountTokenAmount
    public var isNative: Bool
    public var mint: SolanaPublicKey
    public var owner: SolanaPublicKey
}

public struct SolanaRPCTokenAccountDataParsed: Decodable {
    public var type: String
    public var info: SolanaRPCTokenAccountinfo
}

public struct SolanaRPCTokenAccountData: Decodable {
    public var program: String
    public var parsed: SolanaRPCTokenAccountDataParsed
}

public struct SolanaRPCTokenAccount: Decodable {
    public var data: SolanaRPCTokenAccountData
    public var executable: Bool
    public var lamports: UInt64
    public var owner: SolanaPublicKey
}

public struct SolanaRPCTokenAccountsByOwner: Decodable {
    public var pubkey: SolanaPublicKey
    public var account: SolanaRPCTokenAccount
}

public struct SolanaRPCTokenAccountsByOwnerResult: Decodable {
    public var value: [SolanaRPCTokenAccountsByOwner]
}



public struct SolanaRPCTokenSupply: Decodable {
    public var amount: String
    public var decimals: Int
}

public struct SolanaRPCTokenSupplyResult: Decodable {
    public var value: SolanaRPCTokenSupply
}

public struct SolanaRPCEpochInfoResult: Codable {
    public var absoluteSlot: UInt64
    public var blockHeight: UInt64
    public var epoch: UInt64
    public var slotIndex: UInt64
    public var slotsInEpoch: UInt64
    public var transactionCount: UInt64?
}

public struct SolanaRPCRecentBlockhash: Decodable {
    public var blockhash: String
    public var feeCalculator: AnyCodable
}

public struct SolanaRPCRecentBlockhashResult: Decodable {
    public var value: SolanaRPCRecentBlockhash
}

public struct SolanaRPCLatestBlockhash: Decodable {
    public var blockhash: String
    public var lastValidBlockHeight: UInt64
}

public struct SolanaRPCLatestBlockhashResult: Decodable {
    public var value: SolanaRPCLatestBlockhash
}

public struct SolanaRPCFeeForMessageResult: Codable {
    public var value: UInt64?
}

public struct SolanaRPCBlanceValueResult: Codable {
    public var value: UInt64
}

public struct SolanaNFTTokenResult {
    public var pubkey: SolanaPublicKey
    public var mint: SolanaPublicKey
    public var owner: SolanaPublicKey
    public var FDAAddress: SolanaPublicKey
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
