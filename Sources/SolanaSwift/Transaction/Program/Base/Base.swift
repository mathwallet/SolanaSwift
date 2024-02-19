//
//  Base.swift
//
//
//  Created by mathwallet on 2024/2/19.
//

import Foundation

public protocol SolanaProgramBase {
    associatedtype T: BorshCodable
    var id: SolanaPublicKey { get }
    var accounts: [SolanaSigner] { get }
    var instruction: T { get }
}
