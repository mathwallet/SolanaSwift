//
//  SolanaInstructionDefult.swift
//  
//
//  Created by xgblin on 2021/11/9.
//

import Foundation

public struct SolanaInstructionDefult: SolanaInstructionBase {
    public var promgramId: SolanaPublicKey
    
    public var signers = [SolanaSigner]()
    
    public let data:Data
    
    public init(promgramId: SolanaPublicKey, signers: [SolanaSigner], data:Data) {
        self.signers = signers
        self.data = data
        self.promgramId = promgramId
    }
    
    public func toData() -> Data {
        return self.data
    }
}
