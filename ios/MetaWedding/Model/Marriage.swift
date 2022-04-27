//
//  Marriage.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 09.04.2022.
//

import Foundation
import BigInt

struct Marriage {
    let authorAddress: String
    let receiverAddress: String
    let divorceState: DivorceState
    let divorceRequestTimestamp: BigUInt
    let divorceTimeout: BigUInt
    let timestamp: BigUInt
    let metaUrl: String
    let conditions: String
    
    init(authorAddress: String,
         receiverAddress: String,
         divorceState: DivorceState,
         divorceRequestTimestamp: BigUInt,
         divorceTimeout: BigUInt,
         timestamp: BigUInt,
         metaUrl: String,
         conditions: String) {
        self.authorAddress = authorAddress
        self.receiverAddress = receiverAddress
        self.divorceState = divorceState
        self.divorceRequestTimestamp = divorceRequestTimestamp
        self.divorceTimeout = divorceTimeout
        self.timestamp = timestamp
        self.metaUrl = metaUrl
        self.conditions = conditions
    }
    
    init() {
        self.authorAddress = ""
        self.receiverAddress = ""
        self.divorceState = .notRequested
        self.divorceRequestTimestamp = 0
        self.divorceTimeout = 0
        self.timestamp = 0
        self.metaUrl = ""
        self.conditions = ""
    }
    
    func isEmpty() -> Bool {
        authorAddress.isEmpty
    }
}
