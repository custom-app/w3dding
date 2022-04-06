//
//  Wallets.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import Foundation

struct Wallet: Hashable {
    let appStoreLink: String
    let deepLinkScheme: String
    let name: String
    let gasPriceRequired: Bool
    
    var isUniversal: Bool {
        deepLinkScheme.starts(with: "https")
    }
    
    func formWcDeepLink(connectionUrl: String) -> String {
        if isUniversal {
            return "\(deepLinkScheme)/wc?uri=\(connectionUrl)"
        } else {
            return "\(deepLinkScheme)://wc?uri=\(connectionUrl)"
        }
    }
}

struct Wallets {
    
    static let TrustWallet = Wallet(
        appStoreLink: "https://apps.apple.com/app/apple-store/id1288339409",
        deepLinkScheme: "https://link.trustwallet.com",
        name: "Trust Wallet",
        gasPriceRequired: false
    )
    
    static let Metamask = Wallet(
        appStoreLink: "https://apps.apple.com/app/metamask/id1438144202",
        deepLinkScheme: "https://metamask.app.link",
        name: "Metamask",
        gasPriceRequired: false
    )
    
    static let Safepal = Wallet(
        appStoreLink: "https://apps.apple.com/app/safepal-wallet/id1548297139",
        deepLinkScheme: "https://link.safepal.io",
        name: "Safepal",
        gasPriceRequired: true
    )
    
    static let TokenPocket = Wallet(
        appStoreLink: "https://apps.apple.com/app/tokenpocket-trusted-wallet/id1436028697",
        deepLinkScheme: "tpoutside",
        name: "Token Pocket",
        gasPriceRequired: false
    )
    
    static let UnstoppableWallet = Wallet(
        appStoreLink: "https://apps.apple.com/app/bank-bitcoin-wallet/id1447619907",
        deepLinkScheme: "https://unstoppable.money",
        name: "Unstoppable Wallet",
        gasPriceRequired: false
    )
    
    static let AlphaWallet = Wallet(
        appStoreLink: "https://apps.apple.com/app/alphawallet-eth-wallet/id1358230430",
        deepLinkScheme: "https://aw.app",
        name: "Alpha Wallet",
        gasPriceRequired: false
    )
    
    static let MathWallet = Wallet(
        appStoreLink: "https://apps.apple.com/app/mathwallet5/id1582612388",
        deepLinkScheme: "https://www.mathwallet.org",
        name: "Math Wallet",
        gasPriceRequired: false
    )
    
    static let All = [TrustWallet, Metamask, Safepal, TokenPocket, UnstoppableWallet, AlphaWallet, MathWallet]
}
