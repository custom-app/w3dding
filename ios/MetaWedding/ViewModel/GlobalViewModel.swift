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
import PhotosUI

class GlobalViewModel: ObservableObject {
    
    private let gasSafeAddition: BigUInt = 3000000000
    public let nameLimit = 50
    private let deepLinkDelay = 0.5
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
    @Published
    var faucetRequested = false
    
    var backgroundManager = BackgroundTasksManager()
    
    @Published
    var sendTxPending = false
    
    @Published
    var alert: IdentifiableAlert?
    
    @Published
    var name: String = ""
    @Published
    var partnerAddress: String = ""
    
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
    var showConstructorSheet: Bool = false
    
    @Published
    var showWebView = false
 
    @Published
    var certificateHtml = ""
    @Published
    var previewHtml = ""
    
    @Published
    var isProposalActionPending = false
    
    @Published
    var angle: Double = 0.0
    @Published
    var isAnimating = false
    
    @Published
    var selfImage: UIImage?
    @Published
    var partnerImage: UIImage?
    
    @Published
    var selectedTemplate = Constants.templates[0]
    @Published
    var templates: [CertificateTemplate] = Constants.templates
    
    @Published
    var previewImage: UIImage?
    
    @Published
    var showPreviewWebView = false
    
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
        backgroundManager.finishProposalBackgroundTask()
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
        withAnimation {
            self.isProposalActionPending = false
        }
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
                self?.handleResponse(response, label: label)
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
    
    private func handleResponse(_ response: Response, label: String) {
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
                self.showConstructorSheet = false
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
                print("balance: \(balance)")
                if error == nil {
                    withAnimation {
                        self?.balance = balance
                        if balance != 0 {
                            self?.faucetRequested = false
                        }
                    }
                }
            }
        }
    }
    
    func callFaucet() {
        if let address = walletAccount {
            withAnimation {
                faucetRequested = true
            }
            web3.callFaucet(to: address) { err in
                if err == nil {
                    print("faucet called")
                } else {
                    withAnimation {
                        self.faucetRequested = false
                    }
                    print("Faucet error: \(err)")
                    self.alert = IdentifiableAlert.build(
                        id: "faucet error",
                        title: "Faucet error",
                        message: "Faucet is closed or you already used it for current address"
                    )
                }
            }
        }
    }
    
    func requestBlockHash(_ id: BigUInt, onResult: @escaping (String, Error?) -> ()) {
        web3.getBlockHash(blockId: id, onResult: onResult)
    }
    
    func requestCurrentMarriage() {
        if let address = walletAccount {
            web3.getCurrentMarriage(address: address) { [weak self] marriage, error in
                print("got marriage result")
                if let error = error {
                    print("got marriage error \(error)")
                    self?.isErrorLoading = true
                } else {
                    print("marriage info:\n\(marriage)")
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
                        if i < self.authoredProposals.count { //TODO: find by id instead of index
                            DispatchQueue.main.async {
                                withAnimation {
                                    self.authoredProposals[i].meta = meta
                                }
                                if !meta.properties.firstPersonImage.isEmpty {
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: meta.properties.firstPersonImage))!
                                        URLSession.shared.dataTask(with: url) { [self] data, response, error in
                                            guard error == nil, let data = data else {
                                                return
                                            }
                                            let image = UIImage(data: data)
                                            if i < self.authoredProposals.count { //TODO: find by id instead of index
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        self.authoredProposals[i].authorImage = image
                                                    }
                                                }
                                            }
                                        }
                                        .resume()
                                    }
                                }
                                if !meta.properties.secondPersonImage.isEmpty {
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: meta.properties.secondPersonImage))!
                                        URLSession.shared.dataTask(with: url) { [self] data, response, error in
                                            guard error == nil, let data = data else {
                                                return
                                            }
                                            let image = UIImage(data: data)
                                            if i < self.authoredProposals.count { //TODO: find by id instead of index
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        self.authoredProposals[i].receiverImage = image
                                                    }
                                                }
                                            }
                                        }
                                        .resume()
                                    }
                                }
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
                        if i < self.receivedProposals.count {
                            DispatchQueue.main.async {
                                withAnimation {
                                    self.receivedProposals[i].meta = meta
                                }
                                if !meta.properties.firstPersonImage.isEmpty {
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: meta.properties.firstPersonImage))!
                                        URLSession.shared.dataTask(with: url) { [self] data, response, error in
                                            guard error == nil, let data = data else {
                                                return
                                            }
                                            let image = UIImage(data: data)
                                            if i < self.receivedProposals.count { //TODO: find by id instead of index
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        self.receivedProposals[i].authorImage = image
                                                    }
                                                }
                                            }
                                        }
                                        .resume()
                                    }
                                }
                                if !meta.properties.secondPersonImage.isEmpty {
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: meta.properties.secondPersonImage))!
                                        URLSession.shared.dataTask(with: url) { [self] data, response, error in
                                            guard error == nil, let data = data else {
                                                return
                                            }
                                            let image = UIImage(data: data)
                                            if i < self.receivedProposals.count { //TODO: find by id instead of index
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        self.receivedProposals[i].receiverImage = image
                                                    }
                                                }
                                            }
                                        }
                                        .resume()
                                    }
                                }
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
        requestBalance()
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
    
    func openPhotoPicker(onSuccess: @escaping () -> ()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            onSuccess()
        case .denied, .restricted:
            alert = IdentifiableAlert.build(
                id: "photo library access",
                title: "Access denied",
                message: "You need to give permission for photos in settings"
            )
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    onSuccess()
                }
            }
        @unknown default:
            print("Unknown photo library authorization status")
        }
    }
    
    func handleSelfPhotoPicked(photo: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let compressed = CertificateWorker.compressImage(image: photo)
            DispatchQueue.main.async {
                withAnimation {
                    self.selfImage = compressed
                }
            }
        }
    }
    
    func uploadImageToIpfs(image: UIImage,
                           quality: Double = 0.75,
                           onSuccess: @escaping (String) -> ()) {
        print("uploading image to ipfs")
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            guard let data = image.jpegData(compressionQuality: quality) else {
                print("error getting jpeg data for photo")
                onProposalProcessFinish()
                handleError(InnerError.nilJpegData)
                return
            }
            HttpRequester.shared.uploadPictureToNftStorage(data: data) { response, error in
                if let error = error {
                    print("Error uploading photo: \(error)")
                    self.onProposalProcessFinish()
                    self.handleError(error)
                    return
                }
                if let response = response {
                    if response.ok {
                        print("image successfully uploaded: \(response.value.cid)")
                        onSuccess(response.value.cid)
                    } else {
                        print("image upload not ok")
                        self.onProposalProcessFinish()
                        self.handleError(InnerError.httpError(body: "\(response)"))
                    }
                }
            }
        }
    }
    
    func uploadMetaToIpfs(meta: CertificateMeta, onSuccess: @escaping (String) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            HttpRequester.shared.uploadMetaToNftStorage(meta: meta) { response, error in
                if let error = error {
                    print("Error uploading certificate meta: \(error)")
                    self.onProposalProcessFinish()
                    return
                }
                if let response = response {
                    self.onProposalProcessFinish()
                    if response.ok {
                        print("certificate meta successfully uploaded, url: \(response.value.url)")
                        onSuccess(response.value.url)
                    } else {
                        print("certificate meta upload not ok")
                        self.handleError(InnerError.httpError(body: "\(response)"))
                    }
                }
            }
        }
    }
    
    func sendNewProposal(selfAddress: String,
                         partnerAddress: String,
                         selfName: String,
                         selfImage: UIImage?) {
        withAnimation {
            isProposalActionPending = true
        }
        backgroundManager.createProposalBackgroundTask()
        if let image = selfImage {
            uploadImageToIpfs(image: image) { cid in
                self.uploadNewProposalMeta(selfAddress: selfAddress,
                                           partnerAddress: partnerAddress,
                                           selfName: selfName,
                                           imageCid: cid)
            }
        } else {
            uploadNewProposalMeta(selfAddress: selfAddress,
                                  partnerAddress: partnerAddress,
                                  selfName: selfName,
                                  imageCid: nil)
        }
    }
    
    func uploadNewProposalMeta(selfAddress: String,
                               partnerAddress: String,
                               selfName: String,
                               imageCid: String?) {
        print("uploading new proposal meta")
        let selfImageUrl = imageCid == nil ? "" : "ipfs://\(imageCid ?? "")"
        let properties = CertificateProperties(
            id: "",
            firstPersonAddress: selfAddress.lowercased(),
            secondPersonAddress: partnerAddress.lowercased(),
            firstPersonName: selfName,
            secondPersonName: "",
            firstPersonImage: selfImageUrl,
            secondPersonImage: "",
            templateId: "",
            blockNumber: ""
        )
        let meta = CertificateMeta(name: "W3dding certificate",
                                   description: "Marriage certificate info",
                                   image: "",
                                   properties: properties)
        self.uploadMetaToIpfs(meta: meta) { url in
            if self.authoredProposals.contains(where: {
                $0.address.lowercased() == partnerAddress.lowercased()
            }) {
                self.updateProposition(to: partnerAddress.lowercased(),
                                       metaUrl: url)
            } else {
                self.propose(to: partnerAddress.lowercased(),
                             metaUrl: url)
            }
        }
    }
    
    func generateCerificateAndAcceptProposition(proposal: Proposal,
                           properties: CertificateProperties,
                           name: String,
                           image: UIImage?,
                           templateId: String = "1") {
        guard let address = walletAccount else {
            return
        }
        withAnimation {
            isProposalActionPending = true
        }
        backgroundManager.createProposalBackgroundTask()
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            print("getting block hash")
            web3.getBlockHash(blockId: proposal.prevBlockNumber+1) { hash, error in
                print("loaded block hash")
                if let error = error {
                    DispatchQueue.main.async {
                        self.handleError(error)
                        self.onProposalProcessFinish()
                    }
                    return
                }
                if !properties.firstPersonImage.isEmpty {
                    print("loading author image")
                    URLSession.shared.dataTask(with: URL(string: Tools.ipfsLinkToHttp(ipfsLink: properties.firstPersonImage))!) { [self] data, response, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.handleError(error)
                                self.onProposalProcessFinish()
                            }
                            return
                        }
                        guard let data = data else {
                            DispatchQueue.main.async {
                                self.handleError("Got nil data partner image")
                                self.onProposalProcessFinish()
                            }
                            return
                        }
                        print("author photo loaded")
                        let partnerImage = UIImage(data: data) //TODO: pass base64 w/o converting
                        self.buildCertificateWebView(
                            id: String(proposal.tokenId),
                            firstPersonName: properties.firstPersonName,
                            secondPersonName: name,
                            firstPersonAddress: properties.firstPersonAddress,
                            secondPersonAddress: address,
                            firstPersonImage: partnerImage,
                            secondPersonImage: image,
                            templateId: templateId,
                            blockHash: hash,
                            blockNumber: "\(proposal.prevBlockNumber+1)")
                    }
                    .resume()
                } else {
                    self.buildCertificateWebView(
                        id: String(proposal.tokenId),
                        firstPersonName: properties.firstPersonName,
                        secondPersonName: name,
                        firstPersonAddress: properties.firstPersonAddress,
                        secondPersonAddress: address,
                        firstPersonImage: nil,
                        secondPersonImage: image,
                        templateId: templateId,
                        blockHash: hash,
                        blockNumber: "\(proposal.prevBlockNumber+1)")
                }
            }
        }
    }
    
    func buildCertificateWebView(id: String,
                                 firstPersonName: String,
                                 secondPersonName: String,
                                 firstPersonAddress: String,
                                 secondPersonAddress: String,
                                 firstPersonImage: UIImage?,
                                 secondPersonImage: UIImage?,
                                 templateId: String,
                                 blockHash: String,
                                 blockNumber: String,
                                 forPreview: Bool = false) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let firstPersonImageBase64 = firstPersonImage?.base64()
            let secondPersonImageBase64 = secondPersonImage?.base64()
            let htmlString = CertificateWorker.generateHtmlString(
                id: id,
                firstPersonName: firstPersonName,
                secondPersonName: secondPersonName,
                firstPersonAddress: firstPersonAddress,
                secondPersonAddress: secondPersonAddress,
                firstPersonImage: firstPersonImageBase64,
                secondPersonImage: secondPersonImageBase64,
                templateId: templateId,
                blockHash: blockHash,
                blockNumber: blockNumber
            )
            
            DispatchQueue.main.async {
                if forPreview {
                    self.previewHtml = htmlString
                    self.showPreviewWebView = true
                } else {
                    self.certificateHtml = htmlString
                    self.showWebView = true
                }
            }
        }
    }
    
    func uploadCertificateToIpfs(formatter: UIViewPrintFormatter,
                                 id: String,
                                 firstPersonName: String,
                                 secondPersonName: String,
                                 firstPersonAddress: String,
                                 secondPersonAddress: String,
                                 firstPersonImage: String,
                                 blockNumber: String,
                                 templateId: String) {
        backgroundManager.finishProposalBackgroundTask() // need to recreate background task because of 30 sec limit
        backgroundManager.createProposalBackgroundTask()
        do {
            // Can't run on background thread
            guard let pdfUrl = try CertificateWorker.generateCertificatePdf(formatter: formatter) else {
                onProposalProcessFinish()
                handleError(InnerError.nilCertificateUrl)
                return
            }
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                guard let certImage = CertificateWorker.imageFromPdf(url: pdfUrl) else {
                    print("error converting cert pdf to image")
                    onProposalProcessFinish()
                    handleError(InnerError.jpegConverting)
                    return
                }
                if let image = selfImage {
                    uploadImageToIpfs(image: image) { [self] selfImageCid in
                        print("uploaded self image to ipfs, cid: \(selfImageCid)")
                        finishCertificateUploading(certImage: certImage,
                                                   id: id,
                                                   firstPersonName: firstPersonName,
                                                   secondPersonName: secondPersonName,
                                                   firstPersonAddress: firstPersonAddress,
                                                   secondPersonAddress: secondPersonAddress,
                                                   firstPersonImage: firstPersonImage,
                                                   secondPersonImage: "ipfs://\(selfImageCid)",
                                                   blockNumber: blockNumber,
                                                   templateId: templateId)
                    }
                } else {
                    finishCertificateUploading(certImage: certImage,
                                               id: id,
                                               firstPersonName: firstPersonName,
                                               secondPersonName: secondPersonName,
                                               firstPersonAddress: firstPersonAddress,
                                               secondPersonAddress: secondPersonAddress,
                                               firstPersonImage: firstPersonImage,
                                               secondPersonImage: "",
                                               blockNumber: blockNumber,
                                               templateId: templateId)
                }
            }
        } catch {
            print("error generating certificate: \(error)")
            onProposalProcessFinish()
            handleError(error)
        }
    }
    
    func finishCertificateUploading(certImage: UIImage,
                                    id: String,
                                    firstPersonName: String,
                                    secondPersonName: String,
                                    firstPersonAddress: String,
                                    secondPersonAddress: String,
                                    firstPersonImage: String,
                                    secondPersonImage: String,
                                    blockNumber: String,
                                    templateId: String) {
        uploadImageToIpfs(image: certImage) { certCid in
            print("uploaded certificate to ipfs, cid: \(certCid)")
            let properties = CertificateProperties(
                id: id,
                firstPersonAddress: firstPersonAddress,
                secondPersonAddress: secondPersonAddress,
                firstPersonName: firstPersonName,
                secondPersonName: secondPersonName,
                firstPersonImage: firstPersonImage,
                secondPersonImage: secondPersonImage,
                templateId: templateId,
                blockNumber: ""
            )
            let meta = CertificateMeta(name: "W3dding certificate",
                                       description: "Marriage certificate info",
                                       image: "ipfs://\(certCid)",
                                       properties: properties)
            self.uploadMetaToIpfs(meta: meta) { [self] url in
                updateProposition(to: firstPersonAddress, metaUrl: url)
            }
        }
    }
    
    func confirmProposal(to: String, metaUrl: String) {
        acceptProposition(to: to, metaUrl: metaUrl)
    }
    
    func buildPreview(properties: CertificateProperties,
                      name: String,
                      image: UIImage?,
                      templateId: String = "1") {
        guard let address = walletAccount else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            if !properties.firstPersonImage.isEmpty {
                print("loading author image")
                URLSession.shared.dataTask(with: URL(string: Tools.ipfsLinkToHttp(ipfsLink: properties.firstPersonImage))!) { [self] data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.handleError(error)
                        }
                        return
                    }
                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.handleError("Got nil data partner image")
                        }
                        return
                    }
                    print("author photo loaded")
                    let partnerImage = UIImage(data: data) //TODO: pass base64 w/o converting
                    self.buildCertificateWebView(id: "preview",
                                                 firstPersonName: properties.firstPersonName,
                                                 secondPersonName: name,
                                                 firstPersonAddress: properties.firstPersonAddress,
                                                 secondPersonAddress: address,
                                                 firstPersonImage: partnerImage,
                                                 secondPersonImage: image,
                                                 templateId: templateId,
                                                 blockHash: "block hash",
                                                 blockNumber: "block number",
                                                 forPreview: true)
                }
                .resume()
            } else {
                self.buildCertificateWebView(id: "preview",
                                             firstPersonName: properties.firstPersonName,
                                             secondPersonName: name,
                                             firstPersonAddress: properties.firstPersonAddress,
                                             secondPersonAddress: address,
                                             firstPersonImage: nil,
                                             secondPersonImage: image,
                                             templateId: templateId,
                                             blockHash: "block hash",
                                             blockNumber: "block number",
                                             forPreview: true)
            }
        }
    }
    
    func generatePreviewImage(formatter: UIViewPrintFormatter) {
        do {
            // Can't run on background thread
            guard let pdfUrl = try CertificateWorker.generateCertificatePdf(formatter: formatter) else {
                handleError(InnerError.nilCertificateUrl)
                return
            }
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                guard let image = CertificateWorker.imageFromPdf(url: pdfUrl) else {
                    print("error converting cert pdf to image")
                    handleError(InnerError.jpegConverting)
                    return
                }
                DispatchQueue.main.async {
                    self.previewImage = image
                }
            }
        } catch {
            print("error generating certificate: \(error)")
            handleError(error)
        }
    }
    
    func onProposalProcessFinish() {
        DispatchQueue.main.async {
            self.backgroundManager.finishProposalBackgroundTask()
            withAnimation {
                self.isProposalActionPending = false
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
        var accountChanged = false
        if let curSession = self.session,
           let curInfo = curSession.walletInfo,
           let info = session.walletInfo,
           let curAddress = curInfo.accounts.first,
           let address = info.accounts.first,
           curAddress != address || curInfo.chainId != info.chainId {
            accountChanged = true
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
            if accountChanged {
                name = ""
                partnerAddress = ""
                selfImage = nil
                partnerImage = nil
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
