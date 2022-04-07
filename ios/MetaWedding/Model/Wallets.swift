//
//  Wallets.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import Foundation
import UIKit
import WalletConnectSwift

struct Wallet: Hashable {
    let name: String
    let mainUrl: String
    let appStoreLink: String
    let deepLinkScheme: String
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
        name: "Trust Wallet",
        mainUrl: "https://trustwallet.com",
        appStoreLink: "https://apps.apple.com/app/apple-store/id1288339409",
        deepLinkScheme: "https://link.trustwallet.com",
        gasPriceRequired: false
    )

    static let Metamask = Wallet(
        name: "MetaMask",
        mainUrl: "https://metamask.io",
        appStoreLink: "https://apps.apple.com/app/metamask/id1438144202",
        deepLinkScheme: "https://metamask.app.link",
        gasPriceRequired: false
    )

    static let Safepal = Wallet(
        name: "SafePal Wallet",
        mainUrl: "https://safepal.io",
        appStoreLink: "https://apps.apple.com/app/safepal-wallet/id1548297139",
        deepLinkScheme: "https://link.safepal.io",
        gasPriceRequired: true
    )

    static let TokenPocket = Wallet(
        name: "TokenPocket",
        mainUrl: "https://www.tokenpocket.pro",
        appStoreLink: "https://apps.apple.com/app/tokenpocket-trusted-wallet/id1436028697",
        deepLinkScheme: "tpoutside",
        gasPriceRequired: false
    )

    static let UnstoppableWallet = Wallet(
        name: "Unstoppable Wallet",
        mainUrl: "https://unstoppable.money",
        appStoreLink: "https://apps.apple.com/app/bank-bitcoin-wallet/id1447619907",
        deepLinkScheme: "https://unstoppable.money",
        gasPriceRequired: false
    )

    static let AlphaWallet = Wallet(
        name: "AlphaWallet",
        mainUrl: "https://alphawallet.com/",
        appStoreLink: "https://apps.apple.com/app/alphawallet-eth-wallet/id1358230430",
        deepLinkScheme: "https://aw.app",
        gasPriceRequired: false
    )

    static let MathWallet = Wallet(
        name: "MathWallet",
        mainUrl: "https://www.mathwallet.org",
        appStoreLink: "https://apps.apple.com/app/mathwallet5/id1582612388",
        deepLinkScheme: "https://www.mathwallet.org",
        gasPriceRequired: false
    )
    
    static let All = [TrustWallet, Metamask, Safepal, TokenPocket, UnstoppableWallet, AlphaWallet, MathWallet]
    
    static func available() -> [Wallet] {
        var res: [Wallet] = []
        for wallet in All {
            let deepLink = wallet.formWcDeepLink(connectionUrl: "")
            if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                res.append(wallet)
            }
        }
        return res
    }
    
    static func bySession(session: Session?) -> Wallet? {
        guard let session = session else { return nil }
        let name = session.walletInfo?.peerMeta.name
        let url = session.walletInfo?.peerMeta.url
        if let name = name, let wallet = All.first(where: { $0.name == name }) {
            return wallet
        }
        if let url = url?.absoluteString, let wallet = All.first(where: { $0.mainUrl == url } ) {
            return wallet
        }
        return nil
    }
}
