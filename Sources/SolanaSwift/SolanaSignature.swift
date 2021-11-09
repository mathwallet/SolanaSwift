//
//  SolanaSignature.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/27.
//

import Foundation
import Base58Swift

public struct SolanaSignature {
    public var data: Data
    
    public init(data: Data){
        self.data = data
    }
    
    public init?(base58String: String) {
        guard let decodeData = Base58.base58Decode(base58String) else {
            return nil
        }
        self.data = Data(decodeData)
    }
    
    public func base58Sting() -> String {
        return Base58.base58Encode(self.data.bytes)
    }
}
