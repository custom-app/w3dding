//
//  Proposal.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 09.04.2022.
//

import Foundation
import BigInt

class Proposal: Identifiable {
    let address: String
    let metaUrl: String
    let conditions: String
    let divorceTimeout: BigUInt
    let timestamp: BigUInt
    let authorAccepted: Bool
    let receiverAccepted: Bool
    var meta: CertificateMeta? = nil
    
    init(address: String, metaUrl: String, condData: String, divorceTimeout: BigUInt, timestamp: BigUInt, authorAccepted: Bool, receiverAccepted: Bool) {
        self.address = address
        self.metaUrl = metaUrl
        self.conditions = condData
        self.divorceTimeout = divorceTimeout
        self.timestamp = timestamp
        self.authorAccepted = authorAccepted
        self.receiverAccepted = receiverAccepted
        print("address: \(address)")
        print("metaUrl: \(metaUrl)")
        print("condData: \(condData)")
        print("divorceTimeout: \(divorceTimeout)")
        print("timestamp: \(timestamp)")
        print("authorAccepted: \(authorAccepted)")
        print("receiverAccepted: \(receiverAccepted)")
    }
}
