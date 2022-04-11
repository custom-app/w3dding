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
    
    private let gasSafeAddition: BigUInt = 3000000000
    private let defaultGasAmount = "0x5208"
    private let sendTxRequestId = "send_tx"
    
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
    
    var connectBackgroundTaskID: UIBackgroundTaskIdentifier?
    
    var sendTxBackgroundTaskID: UIBackgroundTaskIdentifier?
    
    @Published
    var alert: IdentifiableAlert?
    
    @Published
    var partnerAddress: String = ""
    
    @Published
    var name: String = ""
    
    @Published
    var partnerName: String = ""
    
    @Published
    var isMarriageLoaded = false
    
    @Published
    var marriage: Marriage?
    
    @Published
    var isReceivedProposalsLoaded = false
    
    @Published
    var receivedProposals: [Proposal] = []
    
    @Published
    var isAuthoredProposalsLoaded = false
    
    @Published
    var authoredProposals: [Proposal] = []
    
    
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
        self.connectBackgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Connect to wallet connect") { [weak self] in
            self?.finishBackgroundTask(taskId: self?.connectBackgroundTaskID)
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
        try? client.personal_sign(url: session.url, message: "Hi there!", account: walletAccount!) {
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
                if let error = error {
                    print("error getting gas price: \(error)")
                    self.onMainThread {
                        self.alert = IdentifiableAlert.forError(error: Errors.getGasPrice)
                    }
                } else {
                    let safeGasPrice = gasPrice + self.gasSafeAddition
                    let tx = Stub.tx(from: account,
                                     gas: self.defaultGasAmount,
                                     gasPrice: safeGasPrice.toHexString())
                    do {
                        try client.eth_sendTransaction(url: session.url,
                                                       transaction: tx) { [weak self] response in
                            self?.handleReponse(response, expecting: self?.sendTxRequestId ?? "")
                        }
                        self.onMainThread {
                            self.sendTxBackgroundTaskID =
                            UIApplication.shared.beginBackgroundTask (withName: "Send tx") { [weak self] in
                                self?.finishBackgroundTask(taskId: self?.sendTxBackgroundTaskID)
                            }
                            withAnimation {
                                self.sendTxPending = true
                            }
                        }
                    } catch {
                        print("error sending tx: \(error)")
                        self.onMainThread {
                            self.alert = IdentifiableAlert.forError(error: error.localizedDescription)
                        }
                    }
                }
            }
        } else {
            let tx = Stub.tx(from: account)
            do {
                try client.eth_sendTransaction(url: session.url,
                                               transaction: tx) { [weak self] response in
                    self?.handleReponse(response, expecting: self?.sendTxRequestId ?? "")
                }
                onMainThread {
                    self.sendTxBackgroundTaskID =
                    UIApplication.shared.beginBackgroundTask (withName: "Send tx") { [weak self] in
                        self?.finishBackgroundTask(taskId: self?.sendTxBackgroundTaskID)
                    }
                    withAnimation {
                        self.sendTxPending = true
                    }
                }
            } catch {
                print("error sending tx: \(error)")
                self.onMainThread {
                    self.alert = IdentifiableAlert.forError(error: error.localizedDescription)
                }
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
        if expecting == self.sendTxRequestId {
            onMainThread {
                self.finishBackgroundTask(taskId: self.sendTxBackgroundTaskID)
                withAnimation {
                    self.sendTxPending = false
                }
            }
        }
        self.onMainThread {
            if let error = response.error {
                print("got error on response: \(error)")
                self.alert = IdentifiableAlert.forError(error: error.localizedDescription)
                return
            }
            do {
                let result = try response.result(as: String.self)
                print("got response result: \(result)")
            } catch {
                print("Unexpected response type error: \(error)")
                self.alert = IdentifiableAlert.forError(error: Errors.unknownError)
            }
        }
    }
    
    func requestBalance() {
        if let address = walletAccount  {
            web3.getBalance(address: address) { [weak self] balance, error in
                if let error = error {
                    // handle error?
                } else {
                    self?.balance = balance
                }
            }
        }
    }
    
    func requestCurrentMarriage() {
        if let address = walletAccount  {
            web3.getCurrentMarriage(address: address) { [weak self] marriage, error in
                if let error = error {
                    //TODO: handle error
                } else {
                    if marriage.isEmpty() {
                        self?.requestOutgoingProposals()
                        self?.requestIncomingProposals()
                    } else {
                        withAnimation {
                            self?.marriage = marriage
                        }
                    }
                    withAnimation {
                        self?.isMarriageLoaded = true
                    }
                }
            }
        }
    }
    
    func requestIncomingProposals() {
        if let address = walletAccount  {
            web3.getIncomingPropositions(address: address) { [weak self] incomingProposals, error in
                if let error = error {
                    //TODO: handle error
                } else {
                    withAnimation {
                        self?.receivedProposals = incomingProposals
                        self?.isReceivedProposalsLoaded = true
                    }
                }
            }
        }
    }
    
    func requestOutgoingProposals() {
        if let address = walletAccount  {
            web3.getOutgoingPropositions(address: address) { [weak self] outgoingProposals, error in
                if let error = error {
                    //TODO: handle error
                } else {
                    withAnimation {
                        self?.authoredProposals = outgoingProposals
                        self?.isAuthoredProposalsLoaded = true
                    }
                }
            }
        }
    }
    
    func finishBackgroundTask(taskId: UIBackgroundTaskIdentifier?) {
        if let taskId = taskId {
            UIApplication.shared.endBackgroundTask(taskId)
            self.connectBackgroundTaskID = nil
        }
    }
    
}

extension GlobalViewModel: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        finishBackgroundTask(taskId: connectBackgroundTaskID)
        onMainThread { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
            }
            self.onMainThread {
                self.alert = IdentifiableAlert.forError(error: Errors.failedToConnect)
            }
        }
    }

    func didConnect() {
        print("did connect")
        finishBackgroundTask(taskId: connectBackgroundTaskID)
        onMainThread { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
                session = walletConnect?.session
                if currentWallet == nil {
                    currentWallet = Wallets.bySession(session: session)
                }
                requestBalance()
                requestCurrentMarriage()
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
            finishBackgroundTask(taskId: connectBackgroundTaskID)
            onMainThread { [unowned self] in
                withAnimation {
                    isConnecting = false
                    session = nil
                }
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
