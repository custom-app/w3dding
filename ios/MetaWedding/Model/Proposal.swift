//
//  Proposal.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 09.04.2022.
//

import Foundation

class Proposal: ObservableObject {
    let receiverAddress: String
    let metaUrl: String
    let conditions: String
    let divorseTimeout: Int64
    let authorAccepted: Bool
    let receiverAccepted: Bool
    
    init(receiverAddress: String,
         metaUrl: String,
         conditions: String,
         divorseTimeout: Int64,
         authorAccepted: Bool,
         receiverAccepted: Bool) {
        self.receiverAddress = receiverAddress
        self.metaUrl = metaUrl
        self.conditions = conditions
        self.divorseTimeout = divorseTimeout
        self.authorAccepted = authorAccepted
        self.receiverAccepted = receiverAccepted
    }
}
