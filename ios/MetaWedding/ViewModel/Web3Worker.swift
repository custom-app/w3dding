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
                    print("Balance: \(balanceResult)")
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
}
