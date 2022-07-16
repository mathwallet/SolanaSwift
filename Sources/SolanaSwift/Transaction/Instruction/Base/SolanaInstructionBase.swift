//
//  SolanaInstuctionBase.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation

public protocol SolanaInstructionBase {
    func getPromgramId() -> SolanaPublicKey
    func getSigners() -> [SolanaSigner]
}
