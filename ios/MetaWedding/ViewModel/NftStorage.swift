//
//  NftStorage.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 15.04.2022.
//

import Foundation

struct UploadResponse: Codable {
    let ok: Bool
    let value: UploadResponseValue
}

struct UploadResponseValue: Codable {
    let cid: String
    let created: String
    let type: String
    let scope: String
    let files: [String]
    let size: Int64
    let name: String
    let pin: Pin
    let deals: [String]
}

struct Pin: Codable {
    let cid: String
    let created: String
    let size: Int64
    let status: String
}
