//
//  Web3.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 04.04.2022.
//

import Foundation
import web3swift
import BigInt

class Web3Worker: ObservableObject {
    
    let zeroAddress = "0x0000000000000000000000000000000000000000"
    
    private let web3: web3
    private let contract: EthereumContract
    private let contractWeb3: web3.web3contract
    
    init(endpoint: String) {
        let chainId = BigUInt(Config.TESTING ? Constants.ChainId.PolygonTestnet : Constants.ChainId.Polygon)
        web3 = web3swift.web3(provider: Web3HttpProvider(URL(string: endpoint)!,
                                                         network: Networks.Custom(networkID: chainId))!)
        let path = Bundle.main.path(forResource: "abi", ofType: "json")!
        let abiString = try! String(contentsOfFile: path)
        contract = EthereumContract(abiString)!
        let address = Config.TESTING ? Constants.ContractAddress.Testnet : Constants.ContractAddress.Mainnet
        contractWeb3 = web3.contract(abiString, at: EthereumAddress(address)!, abiVersion: 2)!
    }
    
    func getBalance(address: String, onResult: @escaping (Double, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    let balanceResult = try web3.eth.getBalance(address: walletAddress)
                    let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
                    print("Balance: \(balanceString)")
                    DispatchQueue.main.async {
                        if let balance = Double(balanceString) {
                            onResult(balance, nil)
                        } else {
                            onResult(0, InnerError.balanceParseError)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(0, error)
                    }
                }
            }
        } else {
            onResult(0, InnerError.invalidAddress(address: address))
        }
    }
    
    func getGasPrice(onResult: @escaping (BigUInt, Error?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                let estimateGasPrice = try web3.eth.getGasPrice()
                print("Gas price: \(estimateGasPrice)")
                DispatchQueue.main.async {
                    onResult(estimateGasPrice, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    onResult(0, error)
                }
            }
        }
    }
    
    func getIncomingPropositions(address: String, onResult: @escaping ([Proposal], Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    let (proposals, error) = try requestPropositions(address: walletAddress,
                                                                     method: "getIncomingPropositions")
                    DispatchQueue.main.async {
                        onResult(proposals, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InnerError.invalidAddress(address: address))
        }
    }
    
    func getOutgoingPropositions(address: String, onResult: @escaping ([Proposal], Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    let (proposals, error) = try requestPropositions(address: walletAddress,
                                                                     method: "getOutgoingPropositions")
                    DispatchQueue.main.async {
                        onResult(proposals, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InnerError.invalidAddress(address: address))
        }
    }
    
    private func requestPropositions(address: EthereumAddress, method: String) throws -> ([Proposal], Error?) {
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let tx = contractWeb3.read(
            method,
            extraData: Data(),
            transactionOptions: options)!
        let result = try tx.call()
        
        print("Got response for \(method)")
        if let success = result["_success"] as? Bool, !success {
            return ([Proposal](), InnerError.unsuccessfullСontractRead(description: "\(result)"))
        } else {
            let addresses = result["0"] as! [EthereumAddress]
            let proposals = result["1"] as! [[AnyObject]]
            let res = try parseProposals(addresses: addresses, proposals: proposals)
            return (res, nil)
        }
    }
    
    private func parseProposals(addresses: [EthereumAddress], proposals: [[AnyObject]]) throws -> [Proposal] {
        var res: [Proposal] = []
        for (i, elem) in proposals.enumerated() {
            guard let metaUrl = elem[0] as? String,
                  let condData = elem[1] as? String,
                  let divorceTimeout = elem[2] as? BigUInt,
                  let timestamp = elem[3] as? BigUInt,
                  let authorAccepted = elem[4] as? Int,
                  let receiverAccepted = elem[5] as? Int else {
                      throw InnerError.structParseError(description: "Error proposal parse: \(elem)")
            }
            let proposal = Proposal(address: addresses[i].address,
                                metaUrl: metaUrl,
                                condData: condData,
                                divorceTimeout: divorceTimeout,
                                timestamp: timestamp,
                                authorAccepted: authorAccepted == 1,
                                receiverAccepted: receiverAccepted == 1)
            res.append(proposal)
        }
        return res
    }
    
    func getCurrentMarriage(address: String, onResult: @escaping (Marriage, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.from = walletAddress
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let tx = contractWeb3.read(
                        "getCurrentMarriage",
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got current marriage response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult(Marriage(), InnerError.unsuccessfullСontractRead(description: "\(result)"))
                        }
                    } else {
                        let marriage = result["0"] as! [AnyObject]
                        print("marriage count: \(marriage.count)")
                        let res = try parseMarriage(marriage: marriage)
                        DispatchQueue.main.async {
                            onResult(res, nil)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(Marriage(), error)
                    }
                }
            }
        } else {
            onResult(Marriage(), InnerError.invalidAddress(address: address))
        }
    }
    
    private func parseMarriage(marriage: [AnyObject]) throws -> Marriage {
        let divorceState = try parseDivorceState(marriage[2])
        guard let authorAddress = marriage[0] as? EthereumAddress,
              let receiverAddress = marriage[1] as? EthereumAddress,
              let divorceRequestTimestamp = marriage[3] as? BigUInt,
              let divorceTimeout = marriage[4] as? BigUInt,
              let timestamp = marriage[5] as? BigUInt,
              let metaUrl = marriage[6] as? String,
              let conditions = marriage[7] as? String else {
                  throw InnerError.structParseError(description: "Error marriage parse: \(marriage)")
        }
        if authorAddress.address == zeroAddress {
            return Marriage()
        }
        return Marriage(authorAddress: authorAddress.address,
                        receiverAddress: receiverAddress.address,
                        divorceState: divorceState,
                        divorceRequestTimestamp: divorceRequestTimestamp,
                        divorceTimeout: divorceTimeout,
                        timestamp: timestamp,
                        metaUrl: metaUrl,
                        conditions: conditions)
    }
    
    private func parseDivorceState(_ state: AnyObject) throws -> DivorceState {
        guard let state = state as? BigUInt else {
            throw InnerError.structParseError(description: "Error marriage divorce state parse: \(state)")
        }
        switch state { //TODO: use enum method
        case 0:
            return .notRequested
        case 1:
            return .requestedByAuthor
        case 2:
            return .requestedByReceiver
        default:
            throw InnerError.structParseError(description: "Error marriage divorce state parse, unknown state: \(state)")
        }
    }
    
    func proposeData(to: String, metaUrl: String, condData: String) -> String? {
        let address = EthereumAddress(to)!
        return encodeFunctionData(method: "propose",
                                  parameters: [address as AnyObject,
                                               metaUrl as AnyObject,
                                               condData as AnyObject])?.toHexString(withPrefix: true)
    }
    
    func updatePropositionData(to: String, metaUrl: String, condData: String) -> String? {
        let address = EthereumAddress(to)!
        return encodeFunctionData(method: "updateProposition",
                                  parameters: [address as AnyObject,
                                               metaUrl as AnyObject,
                                               condData as AnyObject])?.toHexString(withPrefix: true)
    }
    
    func acceptPropositionData(to: String, metaUrl: String, condData: String) -> String? {
        let address = EthereumAddress(to)!
        let metaUrlHash = Tools.sha256(data: metaUrl.data(using: .utf8)!)
        let condDataHash = Tools.sha256(data: condData.data(using: .utf8)!)
        return encodeFunctionData(method: "acceptProposition",
                                  parameters: [address as AnyObject,
                                               metaUrlHash as AnyObject,
                                               condDataHash as AnyObject])?.toHexString(withPrefix: true)
    }
    
    func requestDivorceData() -> String? {
        return encodeFunctionData(method: "requestDivorce")?.toHexString(withPrefix: true)
    }
    
    func confirmDivorceData() -> String? {
        return encodeFunctionData(method: "confirmDivorce")?.toHexString(withPrefix: true)
    }
    
    private func encodeFunctionData(method: String, parameters: [AnyObject] = [AnyObject]()) -> Data? {
        let foundMethod = contract.methods.filter { (key, value) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else { return nil }
        let abiMethod = foundMethod[method]
        return abiMethod?.encodeParameters(parameters)
    }
}
