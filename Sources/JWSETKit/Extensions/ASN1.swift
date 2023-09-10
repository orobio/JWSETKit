//
//  File.swift
//  
//
//  Created by Amir Abbas Mousavian on 9/9/23.
//

import Foundation
import SwiftASN1

extension ASN1Node.Content {
    var primitive: Data? {
        switch self {
        case .constructed:
            return nil
        case .primitive(let value):
            return Data(value)
        }
    }
    
    var sequence: [ASN1Node]? {
        switch self {
        case .constructed(let nodes):
            return Array(nodes)
        case .primitive:
            return nil
        }
    }
}

extension DER.Serializer {
    mutating func append(_ array: [Data], as identifier: ASN1Identifier) {
        appendConstructedNode(identifier: .sequence) {
            for item in array {
                $0.appendPrimitiveNode(identifier: identifier) {
                    $0 = [UInt8](item)
                }
            }
        }
    }
}