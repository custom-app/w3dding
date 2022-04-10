//
//  Proposal.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 09.04.2022.
//

import Foundation

struct Proposal: Identifiable, Hashable {
    var id: String { address+metaUrl }
    let address: String
    let metaUrl: String
    let conditions: String
    let divorceTimeout: Int64
    let authorAccepted: Bool
    let receiverAccepted: Bool
}
