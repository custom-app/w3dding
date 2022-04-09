//
//  Marriage.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 09.04.2022.
//

import Foundation

class Marriage: ObservableObject {
    let authorAddress: String
    let receiverAddress: String
    let divorceState: DivorceState
    let divorceRequestTimestamp: Int64
    let divorceTimeout: Int64
    let metaUrl: String
    let conditions: String
    
    init(authorAddress: String,
         receiverAddress: String,
         divorceState: DivorceState,
         divorceRequestTimestamp: Int64,
         divorceTimeout: Int64,
         metaUrl: String,
         conditions: String) {
        self.authorAddress = authorAddress
        self.receiverAddress = receiverAddress
        self.divorceState = divorceState
        self.divorceRequestTimestamp = divorceRequestTimestamp
        self.divorceTimeout = divorceTimeout
        self.metaUrl = metaUrl
        self.conditions = conditions
    }
}
