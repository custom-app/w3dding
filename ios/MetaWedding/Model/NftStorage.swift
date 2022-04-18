//
//  NftStorage.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 15.04.2022.
//

import Foundation

struct ImageUploadResponse: Codable {
    let ok: Bool
    let value: ImageUploadValue
}

struct ImageUploadValue: Codable {
    let cid: String
    let created: String?
    let type: String?
    let scope: String?
    let files: [NftStorageFile]?
    let size: Int64?
    let name: String?
    let pin: Pin
    let deals: [Deal]?
}

struct Pin: Codable {
    let cid: String?
    let created: String?
    let size: Int64?
    let status: String
}

struct NftStorageFile: Codable {
    let name: String
    let type: String
}

struct Deal: Codable {
    let status: String
    let lastChanged: String?
    let chainDealId: Int64?
    let datamodelSelector: String?
    let statusText: String?
    let dealActivation: String?
    let dealExpiration: String?
    let miner: String?
    let pieceCid: String?
    let batchRootCid: String?
}

struct MetaUploadResponse: Codable {
    let ok: Bool
    let value: MetaUploadValue
}

struct MetaUploadValue: Codable {
    let ipnft: String
    let url: String
    let data: CertificateMeta
}
