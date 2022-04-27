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
    
    func httpImageLink() -> String {
        return Tools.ipfsLinkToHttp(ipfsLink: image)
    }
    
    init(name: String, description: String, image: String, properties: CertificateProperties) {
        self.name = name
        self.description = description
        self.image = image
        self.properties = properties
    }
    
    init() {
        name = ""
        description = ""
        image = ""
        properties = CertificateProperties(firstPersonAddress: "",
                                           secondPersonAddress: "",
                                           firstPersonName: "",
                                           secondPersonName: "")
    }
    
    func isEmpty() -> Bool {
        return name.isEmpty && description.isEmpty && image.isEmpty
    }
}

struct CertificateProperties: Codable {
    let firstPersonAddress: String
    let secondPersonAddress: String
    let firstPersonName: String
    let secondPersonName: String
}
