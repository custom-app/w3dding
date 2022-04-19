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
    private let proposeId = "propose"
    private let acceptProposalId = "accept_proposal"
    private let updateProposalId = "update_proposal"
    private let requestDivorceId = "request_divorce"
    private let confirmDivorceId = "confirm_divorce"
    
    @Published
    var session: Session?
    
    @Published
    var currentWallet: Wallet?
    
    @Published
    var isConnecting: Bool = false
    
    @Published
    var isReconnecting: Bool = false
    
    @Published
    var isErrorLoading: Bool = false
    
    @Published
    var walletConnect: LocalWalletConnect?
    
    var pendingDeepLink: String?
    
    @Published
    var web3 = Web3Worker(endpoint: Config.TESTING ?
                          Config.PolygonEndpoints.Testnet : Config.PolygonEndpoints.Mainnet)
    
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
    var partnerAddress: String = "0x5f28ba977324e28594E975f8a9453FF77792a6Ed"
    
    @Published
    var name: String = "Name1"
    
    @Published
    var partnerName: String = "Name2"
    
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
    
    @Published
    var showWebView: Bool = false
 
    @Published
    var certificateHtml: String = ""
    
    var isWrongChain: Bool {
        let requiredChainId = Config.TESTING ? Constants.ChainId.PolygonTestnet : Constants.ChainId.Polygon
        if let session = session,
           let chainId = session.walletInfo?.chainId,
           chainId != requiredChainId {
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
            self?.finishConnectBackgroundTask()
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
            self?.handleReponse(response, label: "Signature")
        }
    }
    
    func propose(to: String, metaUrl: String, condData: String = "") {
        guard let data = web3.proposeData(to: to, metaUrl: metaUrl, condData: condData) else { return } // TODO: return error
        sendTx(data: data, label: proposeId)
    }
    
    func updateProposition(to: String, metaUrl: String, condData: String = "") {
        guard let data = web3.updatePropositionData(to: to,
                                                    metaUrl: metaUrl,
                                                    condData: condData) else { return } // TODO: return error
        sendTx(data: data, label: updateProposalId)
    }
    
    func acceptProposition(to: String, metaUrl: String, condData: String = "") {
        guard let data = web3.acceptPropositionData(to: to, metaUrl: metaUrl, condData: condData) else { return } // TODO: return error
        sendTx(data: data, label: acceptProposalId)
    }
    
    func requestDivorce() {
        guard let data = web3.requestDivorceData() else { return } // TODO: return error
        sendTx(data: data, label: requestDivorceId)
    }
    
    func confirmDivorce() {
        guard let data = web3.confirmDivorceData() else { return } // TODO: return error
        sendTx(data: data, label: confirmDivorceId)
    }
    
    func sendTx(data: String = "", label: String) {
        guard let session = session,
              let client = walletConnect?.client,
              let from = walletAccount else { return } //TODO: return error
        if let wallet = currentWallet, wallet.gasPriceRequired {
            web3.getGasPrice { gasPrice, error in
                if let error = error {
                    print("error getting gas price: \(error)")
                    self.onMainThread {
                        self.alert = IdentifiableAlert.forError(error: Errors.getGasPrice)
                    }
                } else {
                    let safeGasPrice = gasPrice + self.gasSafeAddition
                    let tx = TxWorker.construct(from: from,
                                                data: data,
                                                gas: self.defaultGasAmount,
                                                gasPrice: safeGasPrice.toHexString())
                    do {
                        try client.eth_sendTransaction(url: session.url,
                                                       transaction: tx) { [weak self] response in
                            self?.handleReponse(response, label: label)
                        }
                        print("sending tx: \(label)")
                        self.onMainThread {
                            self.sendTxBackgroundTaskID =
                            UIApplication.shared.beginBackgroundTask (withName: "Send tx") { [weak self] in
                                self?.finishSendTxBackgroundTask()
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
            let tx = TxWorker.construct(from: from, data: data)
            do {
                try client.eth_sendTransaction(url: session.url,
                                               transaction: tx) { [weak self] response in
                    self?.handleReponse(response, label: label)
                }
                print("sending tx: \(label)")
                onMainThread {
                    self.sendTxBackgroundTaskID =
                    UIApplication.shared.beginBackgroundTask (withName: "Send tx") { [weak self] in
                        self?.finishSendTxBackgroundTask()
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
    
    private func handleReponse(_ response: Response, label: String) {
        print("hadling response:\(label)")
        if isSendRequestLabel(label: label) {
            onMainThread {
                self.finishSendTxBackgroundTask()
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
    
    private func isSendRequestLabel(label: String) -> Bool {
        return label == proposeId ||
               label == updateProposalId ||
               label == acceptProposalId ||
               label == requestDivorceId ||
               label == confirmDivorceId
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
                print("got marriage result")
                if let error = error {
                    print("got marriage error \(error)")
                    self?.isErrorLoading = true
                } else {
                    if !marriage.isEmpty() {
                        withAnimation {
                            self?.marriage = marriage
                        }
                    }
                    withAnimation {
                        self?.isMarriageLoaded = true
                    }
                    self?.checkAllLoaded()
                }
            }
        }
    }
    
    func requestIncomingProposals() {
        if let address = walletAccount  {
            web3.getIncomingPropositions(address: address) { [weak self] incomingProposals, error in
                if let error = error {
                    print("got incoming proposals error \(error)")
                    //TODO: handle error
                    self?.isErrorLoading = true
                } else {
                    withAnimation {
                        self?.receivedProposals = incomingProposals
                        self?.isReceivedProposalsLoaded = true
                        self?.checkAllLoaded()
                    }
                }
            }
        }
    }
    
    func requestOutgoingProposals() {
        if let address = walletAccount  {
            web3.getOutgoingPropositions(address: address) { [weak self] outgoingProposals, error in
                if let error = error {
                    print("got outgoing proposals error \(error)")
                    //TODO: handle error
                    self?.isErrorLoading = true
                } else {
                    withAnimation {
                        self?.authoredProposals = outgoingProposals
                        self?.isAuthoredProposalsLoaded = true
                        self?.checkAllLoaded()
                    }
                }
            }
        }
    }
    
    func requestAllInfo() {
        print("requesting all info")
        requestIncomingProposals()
        requestOutgoingProposals()
        requestCurrentMarriage()
    }
    
    func refresh() {
        isAuthoredProposalsLoaded = false
        isReceivedProposalsLoaded = false
        isMarriageLoaded = false
        isErrorLoading = false
        requestAllInfo()
    }
    
    func checkAllLoaded() {
        if allLoaded {
            isErrorLoading = false
        }
    }
    
    var allLoaded: Bool {
        return isAuthoredProposalsLoaded && isReceivedProposalsLoaded && isMarriageLoaded
    }
    
    func buildCertificateWebView() {
            if let address = walletAccount {
                certificateHtml = CertificateWorker.htmlTemplate2
                    .replacingOccurrences(of: CertificateWorker.nameKey, with: name)
                    .replacingOccurrences(of: CertificateWorker.partnerNameKey, with: partnerName)
                    .replacingOccurrences(of: CertificateWorker.addressKey, with: address)
                    .replacingOccurrences(of: CertificateWorker.partnerAddressKey, with: partnerAddress)
                showWebView = true
            }
        }
    
    func uploadCertificateToNftStorage(formatter: UIViewPrintFormatter) {
        do {
            guard let pdfUrl = try CertificateWorker.generateCertificatePdf(formatter: formatter) else {
                return
            }
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let image = CertificateWorker.imageFromPdf(url: pdfUrl)
                guard let data = image?.jpegData(compressionQuality: 1.0) else {
                    print("error getting jpeg data")
                    return
                }
                HttpRequester.shared.uploadPictureToNftStorage(data: data) { response, error in
                    if let error = error {
                        print("Error uploading certificate: \(error)")
                        return
                    }
                    if let response = response {
                        if response.ok {
                            print("certificate successfully uploaded: \(response.value.cid)")
                            self.uploadMetaToNftStorage(cid: response.value.cid)
                        } else {
                            print("certificate upload not ok")
                        }
                    }
                }
            }
        } catch {
            print("error generating certificate: \(error)")
        }
    }
    
    func uploadMetaToNftStorage(cid: String) {
        let properties = CertificateProperties(firstPersonAddress: walletAccount!,
                                               secondPersonAddress: partnerAddress,
                                               firstPersonName: name,
                                               secondPersonName: partnerName)
        let meta = CertificateMeta(name: "W3dding certificate",
                                   description: "Marriage certificate info",
                                   image: "ipfs://\(cid)",
                                   properties: properties)
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            HttpRequester.shared.uploadMetaToNftStorage(meta: meta) { response, error in
                if let error = error {
                    print("Error uploading certificate meta: \(error)")
                    return
                }
                if let response = response {
                    if response.ok {
                        print("certificate meta successfully uploaded, url: \(response.value.url)")
                        self.propose(to: self.partnerAddress, metaUrl: response.value.url)
                    } else {
                        print("certificate meta upload not ok")
                    }
                }
            }
        }
    }
    
    func finishConnectBackgroundTask() {
        if let taskId = connectBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.connectBackgroundTaskID = nil
        }
    }
    
    func finishSendTxBackgroundTask() {
        if let taskId = sendTxBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.sendTxBackgroundTaskID = nil
        }
    }
}

extension GlobalViewModel: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        finishConnectBackgroundTask()
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
        finishConnectBackgroundTask()
        onMainThread { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
                session = walletConnect?.session
                if currentWallet == nil {
                    currentWallet = Wallets.bySession(session: session)
                }
                requestBalance()
                if !isWrongChain {
                    requestAllInfo()
                }
            }
        }
    }
    
    func didUpdate(session: Session) {
        var needToRequestData = false
        if let curSession = self.session,
           let curInfo = curSession.walletInfo,
           let info = session.walletInfo,
           let curAddress = curInfo.accounts.first,
           let address = info.accounts.first,
           curAddress != address || curInfo.chainId != info.chainId {
            needToRequestData = true
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
            if needToRequestData {
                requestBalance()
                refresh()
            }
        }
    }

    func didDisconnect(isReconnecting: Bool) {
        print("did disconnect, is reconnecting: \(isReconnecting)")
        if !isReconnecting {
            finishConnectBackgroundTask()
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
}
