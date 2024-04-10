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
    
    public func getTokenSupply(mint: String, successBlock:@escaping (_ tokenSupply: SolanaTokenSupply)-> Void,failure:@escaping (_ error:Error)-> Void) {
        let params: [Any] = [mint]
        self.sendJsonRpc(method: "getTokenSupply", resultType: SolanaTokenSupplyResult.self, parameters: params) { data in
            successBlock(data.value)
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
    
    public func getNFTTokensByOwner(owner:String,programId: String,filterUrl: String, successBlock:@escaping (_ nftTokens:[SolanaNFTTokenResult])-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.getTokenAccountsByOwner(account: owner, programId: programId) { tokenAccounts in
            self.filterTokenArray(url: filterUrl, owner: owner) { removeResult in
                var tokenMintArray: [String] = [String]()
                removeResult.forEach { collectibleResult in
                    tokenMintArray.append(collectibleResult.chainData?.tokenAccount ?? "")
                }
                var tokenArray:[SolanaNFTTokenResult] = [SolanaNFTTokenResult]()
                for value in tokenAccounts.value! {
                    let amount = Int(value.account?.data?.parsed?.info?.tokenAmount?.amount ?? "0" ) ?? 0
                    let decimals = value.account!.data!.parsed!.info!.tokenAmount!.decimals!
                    if decimals == 0 && !tokenMintArray.contains(value.pubkey ?? "")  {
                        guard let mint = SolanaPublicKey(base58String:value.account!.data!.parsed!.info!.mint!),let FDAAdddress = SolanaPublicKey.createProgramAddress(mint:mint) else {
                            failure(SolanaRpcProviderError.unknown)
                            return
                        }
                        let result = SolanaNFTTokenResult(pubkey: value.pubkey!, mint: value.account!.data!.parsed!.info!.mint!, owner: value.account!.data!.parsed!.info!.owner!, FDAAddress: FDAAdddress.address,amount: amount)
                        tokenArray.append(result)
                    }
                }
                successBlock(tokenArray)
            } failure: { error in
                failure(error)
            }
        } failure: { error in
            failure(error)
        }
    }
        
    public func getMetaData(token:SolanaNFTTokenResult,successBlock:@escaping (_ metaData:MetaPlexMeta)->Void,failure:@escaping (_ error:Error)-> Void) {
        self.getAccountInfo(pubkey: token.FDAAddress, encoding: "base64") { accountInfo in
            if let value = accountInfo.value,let datas = value.data,let base64data = datas.first,let data = Data(base64Encoded: base64data) {
                do {
                    let metaData = try BorshDecoder.decode(MetaPlexMeta.self, from:data)
                    successBlock(metaData)
                } catch {
                    failure(SolanaRpcProviderError.unknown)
                }
            } else {
                failure(SolanaRpcProviderError.unknown)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func getNft(uri:String,successBlock:@escaping (_ nftResult:SolanaNFTResult)->Void,failure:@escaping (_ error:Error)-> Void) {
        AF.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(SolanaNFTResult.self, from: data)
                    successBlock(result)
                } catch let e{
                    failure(e)
                }
            case let .failure(e):
                failure(e)
            }
        }
    }
    
    public func getNfts(owner:String, filterUrl: String, successBlock:@escaping (_ nftTokens:[SolanaNFTTokenResult],_ nfts:[SolanaNFTResult])-> Void,failure:@escaping (_ error:Error)-> Void) {
        var nfts:[SolanaNFTResult] = [SolanaNFTResult]()
        self.getNFTTokensByOwner(owner: owner, programId: SolanaPublicKey.TOKEN_PROGRAM_ID.address, filterUrl: filterUrl, successBlock: { nftTokens in
            let queue = DispatchQueue(label: "solana", attributes: .concurrent)
            let group = DispatchGroup()
            nftTokens.forEach { nftToken in
                group.enter()
                queue.async {
                    self.getMetaData(token: nftToken) { metaData in
                        self.getNft(uri: metaData.data.uri) { nftResult in
                            for _ in 0..<nftToken.amount {
                                nfts.append(SolanaNFTResult(_id: nftResult._id, image: nftResult.image, description: nftResult.description, name: nftResult.name, mint: nftToken.mint, symbol: nftResult.symbol))
                            }
                            group.leave()
                        } failure: { error in
//                            failure(error)
                            group.leave()
                        }
                    } failure: { error in
//                        failure(error)
                        group.leave()
                    }
                }
            }
            group.notify(queue: queue, work: DispatchWorkItem(block: {
                DispatchQueue.main.async {
                    successBlock(nftTokens,nfts)
                }
            }))
        }, failure: failure)
    }
    
    public func filterTokenArray(url: String = "https://a5.maiziqianbao.net/api/v1/collectibles/phantom_collectibles_v1", owner: String, successBlock: @escaping(_ removeResult: [SolanaTokenCollectibleResult]) -> Void, failure: @escaping (_ error:Error) -> Void) {
        AF.request("\(url)/\(owner)", encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(SolanaTokenFilterResult.self, from: data)
                    guard let collectibles = result.data?.collectibles else {
                        failure(SolanaRpcProviderError.unknown)
                        return
                    }
                    let removeResult = collectibles.filter{ $0.chainData?.standard ?? "" != "NonFungible" && $0.collection?.isSpam ?? true == true }
                    successBlock(removeResult)
                } catch let e {
                    failure(e)
                }
            case let .failure(e):
                failure(e)
            }
        }
    }
}

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
}
