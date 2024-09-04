//
//  SolanaRPCProvider.swift
//  
//
//  Created by xgblin on 2021/9/27.
//

import Foundation
import Alamofire

public class SolanaRPCProvider {
    public var requestId: UInt64 = 0
    public var url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func sendJsonRpc<T: Decodable>(
        method: String,
        parameters: [Any]? = nil
    ) async throws -> T {
        self.requestId += 1
        
        let p: Parameters = [
            "method": method,
            "params": parameters ?? [],
            "id": self.requestId,
            "jsonrpc": "2.0"
        ]
        let response = await AF.request(
            url,
            method: .post,
            parameters: p,
            encoding: JSONEncoding.default,
            headers: nil
        ).serializingDecodable(SolanaRpcResult<T>.self).response
        debugPrint(response)
        switch response.result {
        case .success(let r):
            if let result = response.result as? T {
                return result
            } else {
                throw SolanaRpcProviderError.unknown
            }
        case .failure(let error):
            throw error
        }
    }
    
    public func getBlockHeight(
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> UInt64 {
        var parameters: [Any] = []
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let response: UInt64 = try await self.sendJsonRpc(method: "getBlockHeight", parameters: parameters)
        return response
    }
    
    public func getTokenAccountsByOwner(
        account: SolanaPublicKey,
        mint: SolanaPublicKey? = nil,
        programId: SolanaPublicKey? = nil
    ) async throws -> [SolanaRPCTokenAccountsByOwner] {
        var parameters: [Any] = [account.address]
        if let _mint = mint {
            parameters.append(["mint": _mint.address])
        } else if let _programId = programId {
            parameters.append(["programId": _programId.address])
        } else {
            throw SolanaRpcProviderError.unknown
        }
        if let optsParameters = SolanaRPCOptional.getParameters([.encoding(.jsonParsed)]) {
            parameters.append(optsParameters)
        }
        let response: SolanaRPCTokenAccountsByOwnerResult = try await self.sendJsonRpc(method: "getTokenAccountsByOwner", parameters: parameters)
        return response.value
    }
    
    
    public func getTokenSupply(
        mint: SolanaPublicKey,
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> SolanaRPCTokenSupply {
        var parameters: [Any] = [mint.address]
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let result: SolanaRPCTokenSupplyResult = try await self.sendJsonRpc(method: "getTokenSupply", parameters: parameters)
        return result.value
    }
    
    public func getBalance(
        account: SolanaPublicKey,
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> UInt64 {
        var parameters: [Any] = [account.address]
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let result: SolanaRPCBlanceValueResult = try await self.sendJsonRpc(method: "getBalance", parameters: parameters)
        return result.value
    }
    
    public func getLatestBlockhash(
        opts: [SolanaRPCOptional] = [.commitment(.processed)]
    ) async throws -> SolanaRPCLatestBlockhash {
        var parameters: [Any] = []
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let result: SolanaRPCLatestBlockhashResult = try await self.sendJsonRpc(method: "getLatestBlockhash", parameters: parameters)
        return result.value
    }
    
    public func getAccountInfo(
        account: SolanaPublicKey,
        opts: [SolanaRPCOptional] = [.encoding(.base58)]
    ) async throws -> SolanaRPCAccountInfo? {
        var parameters: [Any] = [account.address]
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let result: SolanaRPCAccountInfoResult = try await self.sendJsonRpc(method: "getAccountInfo", parameters: parameters)
        return result.value
    }
    
    public func getEpochInfo(
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> SolanaRPCEpochInfoResult {
        var parameters: [Any] = []
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let response: SolanaRPCEpochInfoResult = try await self.sendJsonRpc(method: "getEpochInfo", parameters: parameters)
        return response
    }
    
    public func getMinimumBalanceForRentExemption(
        usize: UInt64? = nil,
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> UInt64 {
        var parameters: [Any] = []
        if let _usize = usize {
            parameters.append(_usize)
        }
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let response: UInt64 = try await self.sendJsonRpc(method: "getMinimumBalanceForRentExemption", parameters: parameters)
        return response
    }
    
    public func getFeeForMessage(
        message: SolanaMessage,
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> UInt64? {
        let encodedMessage = try! BorshEncoder().encode(message).base64EncodedString()
        var parameters: [Any] = [encodedMessage]
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let response: SolanaRPCFeeForMessageResult = try await self.sendJsonRpc(method: "getFeeForMessage", parameters: parameters)
        return response.value
    }
    
    public func sendTransaction(
        encodedString: String,
        opts: [SolanaRPCOptional]? = nil
    ) async throws -> String {
        var parameters: [Any] = [encodedString]
        if let optsParameters = SolanaRPCOptional.getParameters(opts) {
            parameters.append(optsParameters)
        }
        let response: String = try await self.sendJsonRpc(method: "sendTransaction", parameters: parameters)
        return response
    }
}

extension SolanaRPCProvider {
    
    public func getNFTTokensByOwner(owner: SolanaPublicKey, programId: SolanaPublicKey, filterUrl: String) async throws -> [SolanaNFTTokenResult] {
        let tokenAccounts = try await self.getTokenAccountsByOwner(account: owner, programId: programId)
        let legitimateResult = try await self.filterTokenArray(url: filterUrl, owner: owner)
        var tokenMintArray: [String] = []
        legitimateResult.forEach { collectibleResult in
            tokenMintArray.append(collectibleResult.chainData?.tokenAccount ?? "")
        }
        var tokenArray: [SolanaNFTTokenResult] = [SolanaNFTTokenResult]()
        for value in tokenAccounts {
            let amount = Int(value.account.data.parsed.info.tokenAmount.amount) ?? 0
            let decimals = value.account.data.parsed.info.tokenAmount.decimals
            if decimals == 0 && tokenMintArray.contains(value.pubkey.address)  {
                let mint = value.account.data.parsed.info.mint
                guard let FDAAdddress = SolanaPublicKey.createProgramAddress(mint: mint) else {
                    throw SolanaRpcProviderError.unknown
                }
                let result = SolanaNFTTokenResult(pubkey: value.pubkey, mint: value.account.data.parsed.info.mint, owner: value.account.data.parsed.info.owner, FDAAddress: FDAAdddress,amount: amount)
                tokenArray.append(result)
            }
        }
        return tokenArray
    }
    
    public func getMetaData(token: SolanaNFTTokenResult) async throws -> MetaPlexMeta {
        let accountInfo = try await self.getAccountInfo(account: token.FDAAddress, opts: [.encoding(.base64)])
        if let _accountInfo = accountInfo, let datas = _accountInfo.data.value as? [Any], let base64data = datas.first as? String, let data = Data(base64Encoded: base64data) {
            let metaData = try BorshDecoder.decode(MetaPlexMeta.self, from: data)
            return metaData
        } else {
            throw SolanaRpcProviderError.unknown
        }
    }
    
    public func getNFT(uri: String) async throws -> SolanaNFTResult {
        let response = await AF.request(
            uri,
            method: .get,
            encoding: JSONEncoding.default,
            headers: nil
        ).serializingDecodable(SolanaNFTResult.self).response
        debugPrint(response)
        switch response.result {
        case .success(let r):
            return r
        case .failure(let error):
            throw error
        }
    }
    
    public func getNFTs(owner: SolanaPublicKey, filterUrl: String) async throws -> ([SolanaNFTTokenResult],[SolanaNFTResult]) {
        let nftTokens = try await self.getNFTTokensByOwner(owner: owner, programId: SolanaPublicKey.TOKEN_PROGRAM_ID, filterUrl: filterUrl)
        let results = await withThrowingTaskGroup(of: [SolanaNFTResult].self) { group in
            for nftToken in nftTokens {
                group.addTask {
                    let metaData = try await self.getMetaData(token: nftToken)
                    let nft = try await self.getNFT(uri: metaData.data.uri)
                    return Array(repeating: SolanaNFTResult(_id: nft._id, image: nft.image, description: nft.description, name: nft.name, mint: nftToken.mint.address, symbol: nft.symbol), count: nftToken.amount)
                }
            }
            var results = [SolanaNFTResult]()
            while !group.isEmpty {
                guard let result = await group.nextResult() else { continue }
                
                switch result {
                case .success(let value):
                    results.append(contentsOf: value)
                case .failure:
                    break
                }
            }
            return results
        }
        return (nftTokens, results)
    }
    
    public func filterTokenArray(
        url: String,
        owner: SolanaPublicKey
    ) async throws -> [SolanaTokenCollectibleResult] {
        let response = await AF.request(
            "\(url)/\(owner.address)",
            method: .get,
            encoding: JSONEncoding.default,
            headers: nil
        ).serializingDecodable(SolanaTokenFilterResult.self).response
        debugPrint(response)
        switch response.result {
        case .success(let r):
            var collections = [SolanaTokenCollectibleResult]()
            if let collectibles = r.data?.collectibles {
                collectibles.forEach { collectible in
                    if let standard = collectible.chainData?.standard,
                       let isSpam = collectible.collection?.isSpam,
                       standard == "NonFungible" && isSpam == false  {
                        collections.append(collectible)
                    }
                }
            }
            return collections
        case .failure(let error):
            throw error
        }
    }
}
