//
//  Web3.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 04.04.2022.
//

import Foundation
import web3swift
import BigInt

class Web3Worker:  ObservableObject {
    
    private let web3: web3
    
    init(endpoint: String) {
        web3 = web3swift.web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
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
            onResult(0, InnerError.invalidAddress)
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
                    let balanceResult = try web3.eth.getBalance(address: walletAddress)
                    let _ = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
                    print("Got incoming propositions")
                    
                    var mockedIncomingProposals: [Proposal] = []
                    let proposal1 = Proposal(address: "0xA4AC36f269d3F524a6A77DabDAe4D55BA9998a05",
                                             metaUrl: "https://google.com",
                                             conditions: "",
                                             divorceTimeout: 60*60,
                                             authorAccepted: true,
                                             receiverAccepted: false)
                    let proposal2 = Proposal(address: "0xeCd6120eDfC912736a9865689DeD058C00C15685",
                                             metaUrl: "https://google.com",
                                             conditions: "",
                                             divorceTimeout: 60*60,
                                             authorAccepted: true,
                                             receiverAccepted: false)
                    mockedIncomingProposals.append(proposal1)
                    mockedIncomingProposals.append(proposal2)
                    DispatchQueue.main.async {
                        onResult(mockedIncomingProposals, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InnerError.invalidAddress)
        }
    }
    
    func getOutgoingPropositions(address: String, onResult: @escaping ([Proposal], Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    let balanceResult = try web3.eth.getBalance(address: walletAddress)
                    let _ = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
                    print("Got outgoin propositions")
                    
                    var mockedIncomingProposals: [Proposal] = []
                    let proposal1 = Proposal(address: "0xA4AC36f269d3F524a6A77DabDAe4D55BA9998a05",
                                             metaUrl: "https://google.com",
                                             conditions: "",
                                             divorceTimeout: 60*60,
                                             authorAccepted: true,
                                             receiverAccepted: false)
                    let proposal2 = Proposal(address: "0xeCd6120eDfC912736a9865689DeD058C00C15685",
                                             metaUrl: "https://google.com",
                                             conditions: "",
                                             divorceTimeout: 60*60,
                                             authorAccepted: true,
                                             receiverAccepted: false)
                    mockedIncomingProposals.append(proposal1)
                    mockedIncomingProposals.append(proposal2)
                    DispatchQueue.main.async {
                        onResult(mockedIncomingProposals, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InnerError.invalidAddress)
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
            onResult(Marriage(), InnerError.invalidAddress)
        }
    }
}
