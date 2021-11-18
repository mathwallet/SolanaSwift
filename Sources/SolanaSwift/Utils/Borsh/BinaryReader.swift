//
//  BinaryReader.swift
//  nearclientios
//
//  Created by Dmytro Kurochka on 22.11.2019.
//

import Foundation

public struct BinaryReader {
    public var cursor: Int
    public let bytes: [UInt8]
    
    public init(bytes: [UInt8]) {
        self.cursor = 0
        self.bytes = bytes
    }
}

extension BinaryReader {
    public mutating func read(count: UInt32) -> [UInt8] {
        let newPosition = self.cursor + Int(count)
        let result = bytes[cursor..<newPosition]
        cursor = newPosition
        return Array(result)
    }
}
