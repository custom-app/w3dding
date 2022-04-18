//
//  MetaErc1155.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 18.04.2022.
//

import Foundation

struct CertificateMeta: Codable {
    let name: String
    let description: String
    let image: String
    let properties: CertificateProperties
}

struct CertificateProperties: Codable {
    let firstPersonAddress: String
    let secondPersonAddress: String
    let firstPersonName: String
    let secondPersonName: String
}
