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
        if lhs.isSigner != rhs.isSigner {
            return lhs.isSigner
        }
        
        if lhs.isWritable != rhs.isWritable {
            return lhs.isWritable
        }
        
        return lhs.publicKey.address.localizedCompare(rhs.publicKey.address) != .orderedDescending
    }
}
