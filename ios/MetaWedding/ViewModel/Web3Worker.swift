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
    
    private let web3: web3
    private let contract: EthereumContract
    private let contractWeb3: web3.web3contract
    
    init(endpoint: String) {
        web3 = web3swift.web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
        let path = Bundle.main.path(forResource: "abi", ofType: "json")!
        let abiString = try! String(contentsOfFile: path)
        contract = EthereumContract(abiString)!
        let address = Constants.TESTING ? Constants.ContractAddress.Testnet : Constants.ContractAddress.Mainnet
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
        let result = try! tx.call()
        
        print("Got reponse for \(method)")
        if let success = result["_success"] as? Bool, !success {
            return ([Proposal](), InnerError.unsuccessfullСontractRead(description: "\(result)"))
        } else {
            let addresses = result["0"] as! [EthereumAddress]
            let proposals = result["1"] as! [[AnyObject]]
            let res = try parseProposals(addresses: addresses, proposals: proposals)
            return (res, nil)
        }
    }
    
    func getCurrentMarriage(address: String, onResult: @escaping (Marriage, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    let balanceResult = try web3.eth.getBalance(address: walletAddress)
                    let _ = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
                    print("Got marriage")
                    
                    let mockedMarriage = Marriage(authorAddress: "0x89e7d8Fe0140523EcfD1DDc4F511849429ecB1c2",
                                                  receiverAddress: "0xA4AC36f269d3F524a6A77DabDAe4D55BA9998a05",
                                                  divorceState: .notRequested,
                                                  divorceRequestTimestamp: 0,
                                                  divorceTimeout: 60*60,
                                                  metaUrl: "https://google.com",
                                                  conditions: "")
                    DispatchQueue.main.async {
                        onResult(Marriage(), nil)
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
