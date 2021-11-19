//
//  File.swift
//  
//
//  Created by xgblin on 2021/11/16.
//

import Foundation

public struct MetaPlexMeta {
    public var key:UInt8
    public var update_authority:SolanaPublicKey
    public var mint:SolanaPublicKey
    public var data:MetaPlexData
}

extension MetaPlexMeta: BorshCodable {
  public func serialize(to writer: inout Data) throws {
    try key.serialize(to: &writer)
    try update_authority.serialize(to: &writer)
    try mint.serialize(to: &writer)
    try data.serialize(to: &writer)
  }

  public init(from reader: inout BinaryReader) throws {
    self.key = try .init(from: &reader)
    self.update_authority = try .init(from: &reader)
    self.mint = try .init(from: &reader)
    self.data = try .init(from: &reader)
  }
}

public struct MetaPlexData {
    public var name:String
    public var symbol:String
    public var uri:String
}

extension MetaPlexData: BorshCodable {
  public func serialize(to writer: inout Data) throws {
    try name.serialize(to: &writer)
    try symbol.serialize(to: &writer)
    try uri.serialize(to: &writer)
  }

  public init(from reader: inout BinaryReader) throws {
    self.name = try .init(from: &reader).replacingOccurrences(of: "\0", with: "")
    self.symbol = try .init(from: &reader).replacingOccurrences(of: "\0", with: "")
    self.uri = try .init(from: &reader).replacingOccurrences(of: "\0", with: "")
  }
}
