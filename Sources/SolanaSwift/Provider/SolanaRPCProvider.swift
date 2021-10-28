//
//  SolanaRPCProvider.swift
//  
//
//  Created by xgblin on 2021/9/27.
//

import Foundation
import Alamofire

public struct SolanaRPCProvider {
    public struct SolanaRpcResult<T: Codable>: Codable {
        public var jsonrpc: String?
        public var id: Int
        public var result: T?
        public var error: SolanaJsonRpcError?
    }
    
    public var nodeUrl:String
    
    public init(nodeUrl: String) {
        self.nodeUrl = nodeUrl
    }
    
    public func sendJsonRpc<T:Codable>(method:String,resultType:T.Type,parameters:Any? = nil,successBlock:@escaping (_ data:T)-> Void,failure:@escaping (_ error:Error)-> Void)  {
        let p:Parameters = ["method": method,
                            "params": parameters as Any,
                            "id": 1,
                            "jsonrpc": "2.0"
        ]
        AF.request(nodeUrl, method: .post, parameters: p, encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(SolanaRpcResult<T>.self, from: data)
                    guard let resultData = result.result else {
                        guard let _ = result.error else {
                            failure(SolanaRpcProviderError.unknown)
                            return
                        }
                        failure(SolanaRpcProviderError.server(message: result.error!.message!))
                        return
                    }
                    successBlock(resultData)
                } catch let e {
                    failure(e)
                }
            case let .failure(e):
                failure(e)
            }
        }
    }
    
    public func getBlockHeight(successBlock:@escaping (_ blockHeight:Int64)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.sendJsonRpc(method: "getBlockHeight", resultType: Int64.self) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getTokenAccountsByOwner(account:String,mint:String?=nil,programId:String? = nil,successBlock:@escaping (_ tokenAccounts:SolanaTokenAccountsByOwner)-> Void,failure:@escaping (_ error:Error)-> Void) {
        var params:[Any]
        if let mintSting = mint, !mintSting.isEmpty  {
            params = [account,["mint":mintSting],["encoding":"jsonParsed"]]
        } else if let programIdSting = programId, !programIdSting.isEmpty   {
            params = [account,["programId":programIdSting],["encoding":"jsonParsed"]]
        } else {
            failure(SolanaRpcProviderError.unknown)
            return
        }
        self.sendJsonRpc(method: "getTokenAccountsByOwner", resultType: SolanaTokenAccountsByOwner.self, parameters: params) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getMainBalance(account:String,successBlock:@escaping (_ balanceValue:SolanaBlanceValue)-> Void,failure:@escaping (_ error:Error)-> Void) {
        let params = [account]
        self.sendJsonRpc(method: "getBalance", resultType: SolanaBlanceValue.self, parameters: params) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getRecentBlockhash(successBlock:@escaping (_ recentBlockhash:SolanaRecentBlockhashResult)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.sendJsonRpc(method: "getRecentBlockhash", resultType: SolanaRecentBlockhashResult.self) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getAccountInfo(pubkey:String,encoding:String = "base58",successBlock:@escaping (_ accountInfo:SolanaJsonRpcAccountResult)-> Void,failure:@escaping (_ error:Error)-> Void) {
        let params:[Any] = [pubkey,["encoding":encoding]]
        self.sendJsonRpc(method: "getAccountInfo" ,resultType: SolanaJsonRpcAccountResult.self, parameters: params) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getEpochInfo(successBlock:@escaping (_ epochInfo:SolanaNodeStatusResult)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.sendJsonRpc(method: "getEpochInfo", resultType: SolanaNodeStatusResult.self) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getMinimumBalance(space:Int,successBlock:@escaping (_ minimumBalance:Int64)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.sendJsonRpc(method: "getMinimumBalanceForRentExemption", resultType: Int64.self) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getFees(successBlock:@escaping (_ feesResult:SolanaRecentBlockhashResult)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.sendJsonRpc(method: "getFees", resultType: SolanaRecentBlockhashResult.self) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
    
    public func sendTransaction(base58:String,successBlock:@escaping (_ transaferHash:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.sendJsonRpc(method: "sendTransaction", resultType: String.self, parameters: [base58]) { data in
            successBlock(data)
        } failure: { error in
            failure(error)
        }
    }
}

extension SolanaRPCProvider {
    public enum SolanaRpcProviderError: Error {
        case unknown
        case server(message: String)
        
        var errorDescription: String? {
            switch self {
            case .server(let message):
                return message
            default:
                return "Unknown error"
            }
        }
    }
}
