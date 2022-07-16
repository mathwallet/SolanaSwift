//
//  SolanaSigner.swift
//  
//
//  Created by math on 2021/9/27.
//

import Foundation

public struct SolanaSigner: CustomStringConvertible {
    
    public var publicKey: SolanaPublicKey
    public var isSigner: Bool = false
    public var isWritable: Bool = false
    
    public init(publicKey: SolanaPublicKey, isSigner: Bool = false, isWritable: Bool = false) {
        self.publicKey = publicKey
        self.isSigner = isSigner
        self.isWritable = isWritable
    }
    
    public var description: String {
        return """
            PublicKey : \(publicKey.address)
            isSigner : \(isSigner)
            isWritable : \(isWritable)
        """
    }
}

extension SolanaSigner: Equatable {
    public static func == (lhs: SolanaSigner, rhs: SolanaSigner) -> Bool {
        return lhs.publicKey == rhs.publicKey
    }
}

extension SolanaSigner: Comparable {
    public static func < (lhs: SolanaSigner, rhs: SolanaSigner) -> Bool {
        if rhs.isSigner && !lhs.isSigner {
            return true
        }
        if (lhs.isSigner == rhs.isSigner) && rhs.isWritable && !lhs.isWritable {
            return true
        }
        return false
    }
}
