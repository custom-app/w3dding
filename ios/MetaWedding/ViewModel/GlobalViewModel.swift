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
    private let deepLinkDelay = 0.5
    private let defaultGasAmount = "0x5208"
    private let proposeId = "propose"
    private let acceptProposalId = "accept_proposal"
    private let updateProposalId = "update_proposal"
    private let requestDivorceId = "request_divorce"
    private let confirmDivorceId = "confirm_divorce"
    
    @Published
    var onAuthTab = true
    @Published
    var showConnectSheet = false
    @Published
    var selectedMyProposals: Bool = true
    
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
    var walletConnect: WalletConnect?
    @Published
    var web3 = Web3Worker(endpoint: Config.TESTING ?
                          Config.PolygonEndpoints.Testnet : Config.PolygonEndpoints.Mainnet)
    
    var pendingDeepLink: String?
    
    @Published
    var balance: Double? = nil
    
    var backgroundManager = BackgroundTasksManager()
    
    @Published
    var sendTxPending = false
    
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
    var marriage: Marriage = Marriage()
    @Published
    var marriageMeta: CertificateMeta?
    @Published
    var isErrorLoadingMeta = false
    @Published
    var isReceivedProposalsLoaded = false
    @Published
    var receivedProposals: [Proposal] = []
    @Published
    var isAuthoredProposalsLoaded = false
    @Published
    var authoredProposals: [Proposal] = []
    
    @Published
    var showWebView = false
 
    @Published
    var certificateHtml = ""
    
    @Published
    var isNewProposalPending = false
    
    @Published
    var angle: Double = 0.0
    @Published
    var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.easeInOut(duration: 1.0)
            .repeatForever(autoreverses: false)
    }

    var walletAccount: String? {
        return session?.walletInfo!.accounts[0].lowercased()
    }
    
    var walletName: String {
        if let name = session?.walletInfo?.peerMeta.name {
            return name
        }
        return currentWallet?.name ?? "wallet"
    }
    
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
            walletConnect = WalletConnect(delegate: self, globalViewModel: self)
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
    
    func disconnect() {
        guard let session = session, let walletConnect = walletConnect else { return }
        try? walletConnect.client?.disconnect(from: session)
        withAnimation {
            self.session = nil
        }
        UserDefaults.standard.removeObject(forKey: Constants.sessionKey)
        isAuthoredProposalsLoaded = false
        isReceivedProposalsLoaded = false
        marriageMeta = nil
        isMarriageLoaded = false
    }
    
    func triggerPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + deepLinkDelay) {
            if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: deeplink into app in store
            }
        }
        backgroundManager.createConnectBackgroundTask()
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
    
    func propose(to: String, metaUrl: String, condData: String = "") {
        backgroundManager.finishCertificateBackgroundTask()
        guard let data = web3.proposeData(to: to, metaUrl: metaUrl, condData: condData) else {
            handleError(InnerError.nilContractMethodData(method: "propose"))
            return
        }
        prepareAndSendTx(data: data, label: proposeId)
    }
    
    func updateProposition(to: String, metaUrl: String, condData: String = "") {
        guard let data = web3.updatePropositionData(to: to,
                                                    metaUrl: metaUrl,
                                                    condData: condData) else {
            handleError(InnerError.nilContractMethodData(method: "updateProposition"))
            return
        }
        prepareAndSendTx(data: data, label: updateProposalId)
    }
    
    func acceptProposition(to: String, metaUrl: String, condData: String = "") {
        guard let data = web3.acceptPropositionData(to: to, metaUrl: metaUrl, condData: condData) else {
            handleError(InnerError.nilContractMethodData(method: "acceptProposition"))
            return
        }
        prepareAndSendTx(data: data, label: acceptProposalId)
    }
    
    func requestDivorce() {
        guard let data = web3.requestDivorceData() else {
            handleError(InnerError.nilContractMethodData(method: "requestDivorce"))
            return
        }
        prepareAndSendTx(data: data, label: requestDivorceId)
    }
    
    func confirmDivorce() {
        guard let data = web3.confirmDivorceData() else {
            handleError(InnerError.nilContractMethodData(method: "confirmDivorce"))
            return
        }
        prepareAndSendTx(data: data, label: confirmDivorceId)
    }
    
    func prepareAndSendTx(data: String = "", label: String) {
        guard session != nil,
              walletConnect?.client != nil,
              let from = walletAccount else {
            handleError(InnerError.nilClientOrSession)
            return
        }
        if let wallet = currentWallet, wallet.gasPriceRequired {
            web3.getGasPrice { gasPrice, error in
                if let error = error {
                    print("error getting gas price: \(error)")
                    self.handleError(Errors.getGasPrice)
                } else {
                    let safeGasPrice = gasPrice + self.gasSafeAddition
                    let tx = TxWorker.construct(from: from,
                                                data: data,
                                                gas: self.defaultGasAmount,
                                                gasPrice: safeGasPrice.toHexString())
                    self.sendTx(tx, label: label)
                }
            }
        } else {
            let tx = TxWorker.construct(from: from, data: data)
            sendTx(tx, label: label)
        }
    }
    
    func sendTx(_ tx: Client.Transaction, label: String) {
        guard let session = session,
              let client = walletConnect?.client else {
            handleError(InnerError.nilClientOrSession)
            return
        }
        do {
            try client.eth_sendTransaction(url: session.url,
                                           transaction: tx) { [weak self] response in
                self?.handleReponse(response, label: label)
            }
            print("sending tx: \(label)")
            onMainThread {
                self.backgroundManager.createSendTxBackgroundTask()
                withAnimation {
                    self.sendTxPending = true
                }
                self.openWallet()
            }
        } catch {
            print("error sending tx: \(error)")
            self.handleError(error)
        }
    }
    
    func openWallet() {
        if let wallet = self.currentWallet {
            if let url = URL(string: wallet.formLinkForOpen()),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: mb show message for wallet verification only in this case?
            }
        }
    }
    
    private func handleReponse(_ response: Response, label: String) {
        print("hadling response:\(label)")
        if isSendRequestLabel(label: label) {
            onMainThread {
                self.backgroundManager.finishSendTxBackgroundTask()
                withAnimation {
                    self.sendTxPending = false
                }
            }
        }
        onMainThread {
            if let error = response.error {
                print("got error on response: \(error)")
                self.handleError(error)
                return
            }
            do {
                let result = try response.result(as: String.self)
                print("got response result: \(result)")
                self.alert = IdentifiableAlert.build(
                    id: "tx success",
                    title: "Transaction has been sent",
                    message: "It should take a few seconds after confirming the transaction. Please refresh the status by swipe down"
                )
            } catch {
                print("Unexpected response type error: \(error)")
                self.handleError(Errors.unknownError)
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
        if let address = walletAccount {
            web3.getBalance(address: address) { [weak self] balance, error in
                if error == nil {
                    self?.balance = balance
                }
            }
        }
    }
    
    func requestCurrentMarriage() {
        if let address = walletAccount {
            web3.getCurrentMarriage(address: address) { [weak self] marriage, error in
                print("got marriage result")
                if let error = error {
                    print("got marriage error \(error)")
                    self?.isErrorLoading = true
                } else {
                    withAnimation {
                        self?.marriage = marriage
                    }
                    withAnimation {
                        self?.isMarriageLoaded = true
                    }
                    self?.checkAllLoaded()
                    if !marriage.isEmpty() {
                        self?.requestMarriageMeta()
                    }
                }
            }
        }
    }
    
    func requestIncomingProposals() {
        if let address = walletAccount  {
            web3.getIncomingPropositions(address: address) { [weak self] incomingProposals, error in
                if let error = error {
                    print("got incoming proposals error \(error)")
                    self?.isErrorLoading = true
                } else {
                    withAnimation {
                        if let oldProposals = self?.receivedProposals,
                           oldProposals.count < incomingProposals.count {
                            self?.selectedMyProposals = false
                        }
                        if incomingProposals.count == 0 {
                            self?.selectedMyProposals = true
                        }
                        self?.receivedProposals = incomingProposals
                        self?.isReceivedProposalsLoaded = true
                        self?.checkAllLoaded()
                        self?.requestReceivedProposalsMeta()
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
                    self?.isErrorLoading = true
                } else {
                    withAnimation {
                        self?.authoredProposals = outgoingProposals
                        self?.isAuthoredProposalsLoaded = true
                        self?.checkAllLoaded()
                        self?.requestAuthoredProposalsMeta()
                    }
                }
            }
        }
    }
    
    func requestMarriageMeta() {
        if !marriage.isEmpty(),
           let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: marriage.metaUrl)) {
            print("requesting certificate meta")
            HttpRequester.shared.loadMeta(url: url) { meta, error in
                if let meta = meta {
                    print("got meta:\(meta)")
                    withAnimation {
                        self.marriageMeta = meta
                        self.isErrorLoadingMeta = false
                    }
                    return
                }
                if let error = error {
                    print("error getting meta: \(error)")
                    self.isErrorLoadingMeta = true
                }
            }
        }
    }
    
    //TODO: refactor for universal authored/received proposals method
    func requestAuthoredProposalsMeta() {
        for (i, proposal) in authoredProposals.enumerated() {
            if let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: proposal.metaUrl)) {
                print("requesting authored proposal meta")
                HttpRequester.shared.loadMeta(url: url) { meta, error in
                    if let meta = meta {
                        print("got authored proposal meta:\(meta)")
                        DispatchQueue.main.async {
                            withAnimation {
                                self.authoredProposals[i].meta = meta
                            }
                        }
                        return
                    }
                    if let error = error {
                        print("error getting authored proposal meta: \(error)")
                        self.authoredProposals[i].meta = CertificateMeta()
                    }
                }
            }
        }
    }
    
    func requestReceivedProposalsMeta() {
        for (i, proposal) in receivedProposals.enumerated() {
            if let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: proposal.metaUrl)) {
                print("requesting received proposal meta")
                HttpRequester.shared.loadMeta(url: url) { meta, error in
                    if let meta = meta {
                        print("got received proposal meta:\(meta)")
                        DispatchQueue.main.async {
                            withAnimation {
                                self.receivedProposals[i].meta = meta
                            }
                        }
                        return
                    }
                    if let error = error {
                        print("error getting received proposal meta: \(error)")
                        self.receivedProposals[i].meta = CertificateMeta()
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
    
    //TODO: refactor for universal authored/received proposals method
    var allReceivedProposalsInfoLoaded: Bool {
        if isReceivedProposalsLoaded {
            for proposal in receivedProposals {
                if proposal.meta == nil {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    var allAuthoredProposalsInfoLoaded: Bool {
        if isAuthoredProposalsLoaded {
            for proposal in authoredProposals {
                if proposal.meta == nil {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func buildCertificateWebView() {
            if let address = walletAccount {
                withAnimation {
                    isNewProposalPending = true
                }
                let now = Date()
                certificateHtml = CertificateWorker.htmlTemplate
                    .replacingOccurrences(of: CertificateWorker.nameKey, with: name)
                    .replacingOccurrences(of: CertificateWorker.partnerNameKey, with: partnerName)
                    .replacingOccurrences(of: CertificateWorker.addressKey, with: address)
                    .replacingOccurrences(of: CertificateWorker.partnerAddressKey, with: partnerAddress.lowercased())
                    .replacingOccurrences(of: CertificateWorker.dayNumKey, with: now.dayOrdinal())
                    .replacingOccurrences(of: CertificateWorker.monthNumKey, with: now.formattedDateString("LLLL").lowercased())
                    .replacingOccurrences(of: CertificateWorker.yearNumKey, with: now.formattedDateString("yyyy"))
                showWebView = true
            }
        }
    
    func uploadCertificateToNftStorage(formatter: UIViewPrintFormatter) {
        backgroundManager.createCertificateBackgroundTask()
        do {
            guard let pdfUrl = try CertificateWorker.generateCertificatePdf(formatter: formatter) else {
                onNewProposalProcessFinish()
                handleError(InnerError.nilCertificateUrl)
                return
            }
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let image = CertificateWorker.imageFromPdf(url: pdfUrl)
                guard let data = image?.jpegData(compressionQuality: 0.75) else {
                    print("error getting jpeg data")
                    onNewProposalProcessFinish()
                    handleError(InnerError.jpegConverting)
                    return
                }
                HttpRequester.shared.uploadPictureToNftStorage(data: data) { response, error in
                    if let error = error {
                        print("Error uploading certificate: \(error)")
                        self.onNewProposalProcessFinish()
                        self.handleError(error)
                        return
                    }
                    if let response = response {
                        if response.ok {
                            print("certificate successfully uploaded: \(response.value.cid)")
                            self.uploadMetaToNftStorage(cid: response.value.cid)
                        } else {
                            print("certificate upload not ok")
                            self.onNewProposalProcessFinish()
                            self.handleError(InnerError.httpError(body: "\(response)"))
                        }
                    }
                }
            }
        } catch {
            print("error generating certificate: \(error)")
            onNewProposalProcessFinish()
            handleError(error)
        }
    }
    
    func uploadMetaToNftStorage(cid: String) {
        let properties = CertificateProperties(firstPersonAddress: walletAccount!,
                                               secondPersonAddress: partnerAddress.lowercased(),
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
                    self.onNewProposalProcessFinish()
                    return
                }
                if let response = response {
                    self.onNewProposalProcessFinish()
                    if response.ok {
                        print("certificate meta successfully uploaded, url: \(response.value.url)")
                        self.propose(to: self.partnerAddress.lowercased(),
                                     metaUrl: response.value.url)
                    } else {
                        print("certificate meta upload not ok")
                        self.handleError(InnerError.httpError(body: "\(response)"))
                    }
                }
            }
        }
    }
    
    func onNewProposalProcessFinish() {
        DispatchQueue.main.async {
            self.backgroundManager.finishCertificateBackgroundTask()
            withAnimation {
                self.isNewProposalPending = false
            }
        }
    }
    
    func handleError(_ error: Error) {
        self.onMainThread {
            self.alert = IdentifiableAlert.forError(error: error.localizedDescription)
        }
    }
    
    func handleError(_ error: String) {
        self.onMainThread {
            self.alert = IdentifiableAlert.forError(error: error)
        }
    }
}

extension GlobalViewModel: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        backgroundManager.finishConnectBackgroundTask()
        onMainThread { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
            }
            self.handleError(Errors.failedToConnect)
        }
    }

    func didConnect() {
        print("did connect")
        backgroundManager.finishConnectBackgroundTask()
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
                showConnectSheet = false
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
            backgroundManager.finishConnectBackgroundTask()
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
