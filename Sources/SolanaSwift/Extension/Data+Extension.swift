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
        self.append(Data(bytes: &t, count: MemoryLayout<UInt16>.size) )
    }
    
    mutating func appendUInt32(_ i: UInt32) {
        var t = CFSwapInt32HostToLittle(i)
        self.append(Data(bytes: &t, count: MemoryLayout<UInt32>.size) )
    }
    
    mutating func appendUInt64(_ i: UInt64) {
        var t = CFSwapInt64HostToLittle(i)
        self.append(Data(bytes: &t, count: MemoryLayout<UInt64>.size) )
    }
    
    mutating func appendVarInt(_ i: UInt64) {
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

extension Data {
    func readUInt8(at offset: Int) -> UInt8 {
        return self.bytes[offset]
    }
    
    func readUInt16(at offset: Int) -> UInt16 {
        let size = MemoryLayout<UInt16>.size
        if self.count < offset + size { return 0 }
        return self.subdata(in: offset..<(offset + size)).withUnsafeBytes {
            return CFSwapInt16LittleToHost($0.load(as: UInt16.self))
        }
    }
    
    func readUInt32(at offset: Int) -> UInt32 {
        let size = MemoryLayout<UInt32>.size
        if self.count < offset + size { return 0 }
        return self.subdata(in: offset..<(offset + size)).withUnsafeBytes {
            return CFSwapInt32LittleToHost($0.load(as: UInt32.self))
        }
    }
    
    func readUInt64(at offset: Int) -> UInt64 {
        let size = MemoryLayout<UInt64>.size
        if self.count < offset + size { return 0 }
        return self.subdata(in: offset..<(offset + size)).withUnsafeBytes {
            return CFSwapInt64LittleToHost($0.load(as: UInt64.self))
        }
    }
    
    func readVarInt(at offset: Int, length: inout Int) -> UInt64 {
        let bytes = self.subdata(in: offset..<self.count)
        var i = 0
        var v: UInt64 = 0, b: UInt8 = 0, by: UInt8 = 0
        repeat {
            b = bytes[i]
            v |= UInt64(UInt32(b & 0x7F) << by)
            by += 7
            i += 1
        } while (b & 0x80) != 0 && by < 32
        
        length = i
        return v
    }
    
    func readString(at offset: Int, len: Int) -> String {
        return String(data: self.subdata(in: offset..<(offset + len)), encoding: .utf8) ?? ""
    }
    
    func readBytes(at offset: Int, len: Int) -> [UInt8] {
        return self.subdata(in: offset..<(offset + len)).bytes
    }
    
    func readPubKey(at offset: Int) -> SolanaPublicKey {
        return SolanaPublicKey(data: self.subdata(in: offset..<(offset + 32)))
    }
}
