//
//  File.swift
//  
//
//  Created by Amir Abbas Mousavian on 9/7/23.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

extension SymmetricKey: JSONWebDecryptingKey {
    public func decrypt<D>(_ data: D) throws -> Data where D : DataProtocol {
        switch data {
        case let data as SealedData:
            return try AES.GCM.open(.init(data), using: self)
        default:
            return try AES.GCM.open(.init(combined: data), using: self)
        }
    }
    
    public func encrypt<D>(_ data: D) throws -> SealedData where D : DataProtocol {
        try .init(AES.GCM.seal(data, using: self))
    }
}

public struct JSONWebKeyAESGCM: JSONWebDecryptingKey {
    public var storage: JSONWebValueStorage

    public var symmetricKey: SymmetricKey {
        get throws {
            guard let keyValue = self.keyValue else {
                throw CryptoKitError.incorrectKeySize
            }
            return SymmetricKey(data: keyValue)
        }
    }
    public static func create(storage: JSONWebValueStorage) throws -> JSONWebKeyAESGCM {
        .init(storage: storage)
    }
    
    public init(storage: JSONWebValueStorage) {
        self.storage = storage
    }
    
    public init(_ keySize: SymmetricKeySize) {
        self.storage = .init()
        self.algorithm = "A\(keySize.bitCount)GCM"
        self.keyValue = Self.random()
    }
    
    public init(_ key: SymmetricKey) throws {
        self.storage = .init()
        self.algorithm = "A\(key.bitCount)GCM"
        self.keyValue = key
    }
    
    private static func random() -> SymmetricKey {
        SymmetricKey(size: .bits128)
    }
    
    public func decrypt<D>(_ data: D) throws -> Data where D : DataProtocol {
        switch data {
        case let data as SealedData:
            return try AES.GCM.open(.init(data), using: symmetricKey)
        default:
            return try AES.GCM.open(.init(combined: data), using: symmetricKey)
        }
    }
    
    public func encrypt<D>(_ data: D) throws -> SealedData where D : DataProtocol {
        try .init(AES.GCM.seal(data, using: symmetricKey))
    }
}
