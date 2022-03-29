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
    
    func initWalletConnect() {
        print("init wallet connect: \(walletConnect == nil)")
        if walletConnect == nil {
            walletConnect = LocalWalletConnect(delegate: self)
            walletConnect?.reconnectIfNeeded()
        }
    }
    
    func connect() {
        guard let walletConnect = walletConnect else { return  }

        let connectionUrl = walletConnect.connect()

//        https://metamask.app.link
//        https://link.safepal.io
//        https://link.trustwallet.com
//        tpoutside:
//        https://www.mathwallet.org
//        https://aw.app
        let deepLinkUrl = "https://metamask.app.link/wc?uri=\(connectionUrl)"
        print("full deep link: \(deepLinkUrl)")
//        deepLinkUrl = "https://link.trustwallet.com/wc?uri=wc:2698CFD9-3EFF-4725-A223-A8C84DA5982E@1?bridge=https%3A%2F%2Fbridge.walletconnect.org%2F&key=291ea4e6e8e8e83a29b12f9d9e9b82fbf19f404290f85e4d6e69783217896958"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = URL(string: deepLinkUrl), UIApplication.shared.canOpenURL(url) {
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
            
//            UIAlertController.showDisconnected(from: self)
        }
    }
}

fileprivate enum Stub {

    static let MATH_ADDRESS = "0xA4AC36f269d3F524a6A77DabDAe4D55BA9998a05"
    static let TRUST_ADDRESS = "0x89e7d8Fe0140523EcfD1DDc4F511849429ecB1c2"
    static let METAMASK_ADDRESS = ""
    static let TP_ADDRESS = ""
    static let SAFEPAL_ADDRESS = ""
    static let ALPHA_ADDRESS = "0x8D2aC318B8173ca3103Ed6099879215E7080c878"
    
    /// https://docs.walletconnect.org/json-rpc-api-methods/ethereum#example-parameters-1
    static func tx(from address: String) -> Client.Transaction {
        return Client.Transaction(from: address,
                                  to: TRUST_ADDRESS,
                                  data: "",
                                  gas: nil,
                                  gasPrice: nil,
                                  value: "0x14DF48080E30000",
                                  nonce: nil,
                                  type: nil,
                                  accessList: nil,
                                  chainId: nil,
                                  maxPriorityFeePerGas: nil,
                                  maxFeePerGas: nil)
    }
}
