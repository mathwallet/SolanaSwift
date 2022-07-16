//
//  Borsh.swift
//  nearclientios
//
//  Created by Dmytro Kurochka on 23.11.2019.
//

import Foundation

public typealias BorshCodable = BorshSerializable & BorshDeserializable

public struct UVarInt {
    public let value: UInt32
    public init<T: FixedWidthInteger>(_ value: T) {
        self.value = UInt32(value)
    }
}

public enum BorshDecodingError: Error {
  case unknownData
}
