//
//  WalletConnect.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.03.2022.
//

import Foundation
import WalletConnectSwift

class LocalWalletConnect {
    var client: Client!
    var session: Session!
    var delegate: WalletConnectDelegate
    var globalViewModel: GlobalViewModel
 
    init(delegate: WalletConnectDelegate, globalViewModel: GlobalViewModel) {
        self.delegate = delegate
        self.globalViewModel = globalViewModel
    }

    func connect() -> String {
        let wcUrl =  WCURL(topic: UUID().uuidString,
                           bridgeURL: URL(string: Constants.Bridges.Gnosis)!,
                           key: try! randomKey())
        let clientMeta = Session.ClientMeta(name: "MetaWedding",
                                            description: "MetaWedding App",
                                            icons: [],
                                            url: URL(string: "https://customapp.tech")!)
        let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString,
                                        peerMeta: clientMeta,
                                        chainId: Constants.PolygonChainId)
        client = Client(delegate: self, dAppInfo: dAppInfo)

        try! client.connect(to: wcUrl)
        return wcUrl.fullyPercentEncodedStr
    }

    func reconnectIfNeeded() {
        if let sessionObject = UserDefaults.standard.object(forKey: Constants.sessionKey) as? Data,
            let session = try? JSONDecoder().decode(Session.self, from: sessionObject) {
            client = Client(delegate: self, dAppInfo: session.dAppInfo)
            try? client.reconnect(to: session)
        }
    }
    
    func haveOldSession() -> Bool {
        if let sessionObject = UserDefaults.standard.object(forKey: Constants.sessionKey) as? Data,
           let _ = try? JSONDecoder().decode(Session.self, from: sessionObject) {
            return true
        }
        return false
    }

    private func randomKey() throws -> String {
        var bytes = [Int8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            return Data(bytes: bytes, count: 32).toHexString()
        } else {
            enum TestError: Error {
                case unknown
            }
            throw TestError.unknown
        }
    }
}

protocol WalletConnectDelegate {
    func failedToConnect()
    func didConnect()
    func didUpdate(session: Session)
    func didDisconnect(isReconnecting: Bool)
}

extension LocalWalletConnect: ClientDelegate {
    func client(_ client: Client, didFailToConnect url: WCURL) {
        delegate.failedToConnect()
    }

    func client(_ client: Client, didConnect url: WCURL) {
        print("did connect")
    }
    
    func client(_ client: Client, didSubscribe url: WCURL) {
        print("did subscribe after new connection")
        globalViewModel.triggerPendingDeepLink()
    }

    func client(_ client: Client, didConnect session: Session) {
        print("did connect")
        self.session = session
        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(sessionData, forKey: Constants.sessionKey)
        delegate.didConnect()
    }

    func client(_ client: Client, didDisconnect session: Session, isReconnecting: Bool) {
        UserDefaults.standard.removeObject(forKey: Constants.sessionKey)
        delegate.didDisconnect(isReconnecting: isReconnecting)
    }

    func client(_ client: Client, didUpdate session: Session) {
        print("did update")
        delegate.didUpdate(session: session)
    }
}

extension WCURL {
    var fullyPercentEncodedStr: String {
        absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    }
}

