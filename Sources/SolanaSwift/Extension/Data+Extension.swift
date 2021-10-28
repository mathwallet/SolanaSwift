//
//  File.swift
//  
//
//  Created by math on 2021/9/27.
//

import Foundation

extension Data {
    mutating func appendUInt8(_ i: UInt8) {
        self.append(i)
    }
    
    mutating func appendUInt16(_ i: UInt16) {
        var t = CFSwapInt16HostToLittle(i)
        self.append(Data(bytes: &t, count: 2) )
    }
    
    mutating func appendUInt32(_ i: UInt32) {
        var t = CFSwapInt32HostToLittle(i)
        self.append(Data(bytes: &t, count: 4) )
    }
    
    mutating func appendUInt64(_ i: UInt64) {
        var t = CFSwapInt64HostToLittle(i)
        self.append(Data(bytes: &t, count: 8) )
    }
    
    mutating func appendVarInt(_ i: Int) {
        var vui = [UInt8]()
        var val = i
        while val >= 128 {
            vui.append(UInt8(val % 128))
            val /= 128
        }
        vui.append(UInt8(val))

        for i in 0..<vui.count-1 {
            vui[i] += 128
        }
        self.append(Data(vui))
    }
    
    mutating func appendVarInt2(_ i: Int) {
        var vui = [UInt8]()
        var t = i
        while t != 0 {
            var b = UInt8(t & 0x7f)
            t = (t >> 7)
            b = b | ( ((t > 0) ? 1 : 0 ) << 7 )
            vui.append(b)
        }
        self.append(Data(vui))
    }
    
        
    mutating func appendString(_ string: String) {
        self.append(string.data(using:.utf8)!)
    }
    
    mutating func appendBytes(_ bytes: [UInt8]) {
        self.append(Data(bytes))
    }
    
    mutating func appendPubKey(_ pubKey: SolanaPublicKey) {
        self.append(pubKey.data)
    }
    
}
