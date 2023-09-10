//
//  File.swift
//  
//
//  Created by Amir Abbas Mousavian on 9/10/23.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

extension SymmetricKey: JSONWebKey {
    public var storage: JSONWebValueStorage {
        get {
            var result = JSONWebValueStorage()
            result["kty"] = "oct"
            withUnsafeBytes {
                result["k", true] = Data($0)
            }
            return result
        }
        mutating set {
            guard let data = newValue["k", true] else { return }
            self = SymmetricKey(data: data)
        }
    }
    
    public static func create(storage: JSONWebValueStorage) throws -> SymmetricKey {
        guard let key = (storage["k", true] as Data?) else {
            throw CryptoKitError.incorrectKeySize
        }
        return SymmetricKey(data: key)
    }
    
    public init(storage: JSONWebValueStorage) {
        self.init(size: .bits128)
        self.storage = storage
    }
    
    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes {
            hasher.combine(bytes: $0)
        }
    }
}

extension SymmetricKey: JSONWebSigningKey {
    public func sign<D>(_ data: D, using algorithm: JSONWebAlgorithm) throws -> Data where D : DataProtocol {
        var algorithm = algorithm
        if algorithm == .none {
            algorithm = self.algorithm
        }
        switch algorithm {
        case .hmacSHA256:
            return try JSONWebKeyHMAC<SHA256>(self).sign(data, using: algorithm)
        case .hmacSHA384:
            return try JSONWebKeyHMAC<SHA384>(self).sign(data, using: algorithm)
        case .hmacSHA512:
            return try JSONWebKeyHMAC<SHA512>(self).sign(data, using: algorithm)
        default:
            throw JSONWebKeyError.unknownAlgorithm
        }
    }
    
    public func validate<S, D>(_ signature: S, for data: D, using algorithm: JSONWebAlgorithm) throws where S: DataProtocol, D : DataProtocol {
        var algorithm = algorithm
        if algorithm == .none {
            algorithm = self.algorithm
        }
        switch algorithm {
        case .hmacSHA256:
            try JSONWebKeyHMAC<SHA256>(self).validate(signature, for: data, using: algorithm)
        case .hmacSHA384:
            try JSONWebKeyHMAC<SHA384>(self).validate(signature, for: data, using: algorithm)
        case .hmacSHA512:
            try JSONWebKeyHMAC<SHA512>(self).validate(signature, for: data, using: algorithm)
        default:
            throw JSONWebKeyError.unknownAlgorithm
        }
    }
}

extension SymmetricKey: JSONWebDecryptingKey {
    fileprivate func aesGCMDecrypt<D>(_ data: D) throws -> Data where D : DataProtocol  {
        switch data {
        case let data as SealedData:
            return try AES.GCM.open(.init(data), using: self)
        default:
            return try AES.GCM.open(.init(combined: data), using: self)
        }
    }
    
    public func decrypt<D>(_ data: D, using algorithm: JSONWebAlgorithm) throws -> Data where D : DataProtocol {
        switch algorithm {
        case .aesEncryptionGCM128, .aesEncryptionGCM192, .aesEncryptionGCM256:
            return try aesGCMDecrypt(data)
        default:
            throw JSONWebKeyError.unknownAlgorithm
        }
        
    }
    
    public func encrypt<D>(_ data: D, using algorithm: JSONWebAlgorithm) throws -> SealedData where D : DataProtocol {
        switch algorithm {
        case .aesEncryptionGCM128, .aesEncryptionGCM192, .aesEncryptionGCM256:
            return try .init(AES.GCM.seal(data, using: self))
        default:
            throw JSONWebKeyError.unknownAlgorithm
        }
    }
}