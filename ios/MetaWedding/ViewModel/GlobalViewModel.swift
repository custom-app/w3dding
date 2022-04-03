//
//  GlobalViewModel.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.03.2022.
//

import SwiftUI
import Foundation
import WalletConnectSwift

class GlobalViewModel: ObservableObject {
    
    @Published
    var session: Session?
    
    @Published
    var isConnected: Bool = false
    
    @Published
    var walletConnect: LocalWalletConnect?
    
    var pendingDeepLink: String?
    
    @Published
    var selectedTab = 1
    
    func initWalletConnect() {
        print("init wallet connect: \(walletConnect == nil)")
        if walletConnect == nil {
            walletConnect = LocalWalletConnect(delegate: self, globalViewModel: self)
            walletConnect?.reconnectIfNeeded()
        }
    }
    
    func connect() {
        guard let walletConnect = walletConnect else { return  }
        let connectionUrl = walletConnect.connect()
        pendingDeepLink = Wallets.Metamask.formWcDeepLink(connectionUrl: connectionUrl)
    }
    
    func triggerPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: deeplink into app in store
            }
        }
    }

    func onMainThread(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
    
    var walletAccount: String? {
        return session?.walletInfo!.accounts[0]
    }
    
    func personalSign() {
        guard let session = session, let client = walletConnect?.client else { return }
        try? client.personal_sign(url: session.url, message: "Hi there!", account: session.walletInfo!.accounts[0]) {
            [weak self] response in
            self?.handleReponse(response, expecting: "Signature")
        }
    }
    
    func sendTx() {
        guard let session = session,
                let client = walletConnect?.client,
                let account = self.walletAccount else { return }
        let transaction = Stub.tx(from: account)
        try? client.eth_sendTransaction(url: session.url, transaction: transaction) { [weak self] response in
            self?.handleReponse(response, expecting: "Send tx response")
        }
    }
    
    func disconnect() {
        guard let session = session, let walletConnect = walletConnect else { return }
        try? walletConnect.client?.disconnect(from: session)
        self.session = nil
        UserDefaults.standard.removeObject(forKey: Constants.sessionKey)
    }
    
    private func handleReponse(_ response: Response, expecting: String) {
        print("hadling response")
        DispatchQueue.main.async {
            if let error = response.error {
                print("got error: \(error)")
//                self.show(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert))
                return
            }
            do {
                let result = try response.result(as: String.self)
                print("got response result")
//                self.show(UIAlertController(title: expecting, message: result, preferredStyle: .alert))
            } catch {
                print("Unexpected response type error: \(error)")
//                self.show(UIAlertController(title: "Error",
//                                       message: "Unexpected response type error: \(error)",
//                                       preferredStyle: .alert))
            }
        }
    }
    
}

extension GlobalViewModel: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        onMainThread { [unowned self] in
            isConnected = false
//            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        print("did connect")
        onMainThread { [unowned self] in
            session = walletConnect?.session
            isConnected = true
        }
    }

    func didDisconnect() {
        print("did disconnect")
        onMainThread { [unowned self] in
            session = nil
            isConnected = false
//            UIAlertController.showDisconnected(from: self)
        }
    }
}

fileprivate enum Stub {

    static let MATH_ADDRESS = "0xA4AC36f269d3F524a6A77DabDAe4D55BA9998a05"
    static let TRUST_ADDRESS = "0x89e7d8Fe0140523EcfD1DDc4F511849429ecB1c2"
    static let METAMASK_ADDRESS = ""
    static let TP_ADDRESS = ""
    static let SAFEPAL_ADDRESS = "0xeCd6120eDfC912736a9865689DeD058C00C15685"
    static let ALPHA_ADDRESS = "0x8D2aC318B8173ca3103Ed6099879215E7080c878"
    static let UNSTOPPABLE_ADDRESS = "0x553234087D6F0BB859c712558183a3B88179c4bD"
    
    /// https://docs.walletconnect.org/json-rpc-api-methods/ethereum#example-parameters-1
    static func tx(from address: String) -> Client.Transaction {
        return Client.Transaction(from: address,
                                  to: TRUST_ADDRESS,
                                  data: "",
                                  gas: nil, //"0x5208"
                                  gasPrice: nil, //"0x826299E00"
                                  value: "0x13FBE85EDC90000", //"0x13FBE85EDC90000"
                                  nonce: nil,
                                  type: nil,
                                  accessList: nil,
                                  chainId: nil,
                                  maxPriorityFeePerGas: nil,
                                  maxFeePerGas: nil)
    }
}
