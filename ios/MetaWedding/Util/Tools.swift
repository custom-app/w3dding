//
//  Tools.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 11.04.2022.
//

import Foundation
import CommonCrypto

class Tools {
    
    static func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}

extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
