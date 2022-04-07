//
//  GlobalViewModel.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.03.2022.
//

import SwiftUI
import Foundation
import WalletConnectSwift
import web3swift
import BigInt
import UIKit

class GlobalViewModel: ObservableObject {
    
    let gasSafeAddition: BigUInt = 3000000000
    
    let defaultGasAmount = "0x5208"
    
    @Published
    var session: Session?
    
    @Published
    var currentWallet: Wallet?
    
    @Published
    var isConnecting: Bool = false
    
    @Published
    var isReconnecting: Bool = false
    
    @Published
    var walletConnect: LocalWalletConnect?
    
    var pendingDeepLink: String?
    
    @Published
    var web3 = Web3Worker(endpoint: Constants.PolygonEndpoints.Mainnet)
    
    @Published
    var balance: Double? = nil
    
    @Published
    var selectedTab = 1
    
    @Published
    var sendTxPending = false
    
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    var isWrongChain: Bool {
        if let session = session,
           let chainId = session.walletInfo?.chainId,
           chainId != Constants.PolygonChainId {
            return true
        }
        return false
    }
    
    func initWalletConnect() {
        print("init wallet connect: \(walletConnect == nil)")
        if walletConnect == nil {
            walletConnect = LocalWalletConnect(delegate: self, globalViewModel: self)
            if walletConnect!.haveOldSession() {
                withAnimation {
                    isConnecting = true
                }
                walletConnect!.reconnectIfNeeded()
            }
        }
    }
    
    func connect(wallet: Wallet) {
        guard let walletConnect = walletConnect else { return  }
        let connectionUrl = walletConnect.connect()
        pendingDeepLink = wallet.formWcDeepLink(connectionUrl: connectionUrl)
        currentWallet = wallet
    }
    
    func triggerPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: deeplink into app in store
            }
        }
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Connect to wallet connect") { [weak self] in
            self?.finishBackgroundTask()
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
              let account = walletAccount else { return }
        
        if let wallet = currentWallet, wallet.gasPriceRequired {
            web3.getGasPrice { gasPrice, error in
                let safeGasPrice = gasPrice + self.gasSafeAddition
                let tx = Stub.tx(from: account,
                                 gas: self.defaultGasAmount,
                                 gasPrice: safeGasPrice.toHexString())
                do {
                    try client.eth_sendTransaction(url: session.url,
                                                   transaction: tx) { [weak self] response in
                        self?.handleReponse(response, expecting: "Send tx response")
                    }
                    self.onMainThread {
                        withAnimation {
                            self.sendTxPending = true
                        }
                    }
                } catch {
                    print("error sending tx: \(error)")
                }
            }
        } else {
            let tx = Stub.tx(from: account)
            do {
                try client.eth_sendTransaction(url: session.url,
                                               transaction: tx) { [weak self] response in
                    self?.handleReponse(response, expecting: "Send tx response")
                }
                onMainThread {
                    withAnimation {
                        self.sendTxPending = true
                    }
                }
            } catch {
                print("error sending tx: \(error)")
            }
        }
    }
    
    func disconnect() {
        guard let session = session, let walletConnect = walletConnect else { return }
        try? walletConnect.client?.disconnect(from: session)
        self.session = nil
        UserDefaults.standard.removeObject(forKey: Constants.sessionKey)
    }
    
    private func handleReponse(_ response: Response, expecting: String) {
        print("hadling response:\(expecting)")
        if expecting == "Send tx response" { //TODO: Change to const
            onMainThread {
                withAnimation {
                    self.sendTxPending = false
                }
            }
        }
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
    
    func requestBalance() {
        if let address = walletAccount  {
            web3.getBalance(address: address) { [weak self] balance, error in
                if let error = error {
                    //handle error
                } else {
                    self?.balance = balance
                }
            }
        }
    }
    
    func finishBackgroundTask() {
        if let taskId = self.backgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.backgroundTaskID = nil
        }
    }
    
}

extension GlobalViewModel: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        finishBackgroundTask()
        onMainThread { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
            }
//            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        print("did connect")
        finishBackgroundTask()
        onMainThread { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
                session = walletConnect?.session
                requestBalance()
            }
        }
    }
    
    func didUpdate(session: Session) {
        var needToRequestBalance = false
        if let curSession = self.session,
           let curInfo = curSession.walletInfo,
           let info = session.walletInfo,
           let curAddress = curInfo.accounts.first,
           let address = info.accounts.first,
           curAddress != address || curInfo.chainId != info.chainId {
            needToRequestBalance = true
            do {
                let sessionData = try JSONEncoder().encode(session)
                UserDefaults.standard.set(sessionData, forKey: Constants.sessionKey)
            } catch {
                print("Error saving session in update: \(error)")
            }
        }
        onMainThread { [unowned self] in
            withAnimation {
                self.session = session
            }
            if needToRequestBalance {
                requestBalance()
            }
        }
    }

    func didDisconnect(isReconnecting: Bool) {
        print("did disconnect, is reconnecting: \(isReconnecting)")
        if !isReconnecting {
            finishBackgroundTask()
            onMainThread { [unowned self] in
                withAnimation {
                    isConnecting = false
                    session = nil
                }
    //            UIAlertController.showDisconnected(from: self)
            }
        }
        onMainThread { [unowned self] in
            withAnimation {
                self.isReconnecting = isReconnecting
            }
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
    static func tx(from address: String, gas: String? = nil, gasPrice: String? = nil) -> Client.Transaction {
        return Client.Transaction(from: address,
                                  to: TRUST_ADDRESS,
                                  data: "",
                                  gas: gas, //"0x5208"
                                  gasPrice: gasPrice, //"0x826299E00"
                                  value: "0x2C68AF0BB140000", //"0x13FBE85EDC90000"
                                  nonce: nil,
                                  type: nil,
                                  accessList: nil,
                                  chainId: nil,
                                  maxPriorityFeePerGas: nil,
                                  maxFeePerGas: nil)
    }
}
