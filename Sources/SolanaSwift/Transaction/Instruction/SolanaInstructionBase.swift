//
//  SolanaInstuctionBase.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation

public protocol SolanaInstructionBase {
    var promgramId: SolanaPublicKey{ get set }
    var signers: [SolanaSigner]{ get set }
    
    func toData() -> Data
}
