//
//  Constants.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import Foundation

struct Constants {
    
    static let certificatesNum = 3
    
    static let sessionKey = "sessionKey"
    
    static let testnetAddress1 = "0x5f28ba977324e28594E975f8a9453FF77792a6Ed"
    static let testnetAddress2 = "0xf12E612DAF7d2893C766ADD26Ce1eA6831A59447"
    static let testnetAddressOleg = "0x0c992620066668d2656A10aEC67046E7633da4A9"
    
    struct Bridges {
        static let Gnosis = "https://safe-walletconnect.gnosis.io/"
        static let Wc = "https://bridge.walletconnect.org"
    }
    
    struct ChainId {
        static let Polygon = 137
        static let PolygonTestnet = 80001
    }
    
    struct WeddingContract {
        static let Mainnet = "0xba21ce6B4Dc183fA5D257584e657B913c90A69dA"
        static let Testnet = "0x8c9d33423E5a3e0500AD388f53facB6754A570B3"
    }
    
    struct FaucetContract {
        static let Mainnet = ""
        static let Testnet = "0xA87AEDC7AbCdEBb5252770027CC1c5cCf500315e"
    }
    
    struct FaucetAccount {
        static let Mainnet = ""
        static let Testnet = "0x9dCb41F58406c5A4F1338b57ca0039Cebc8E1D93"
    }
    
}
