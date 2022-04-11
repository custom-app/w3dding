//
//  TxWorker.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 11.04.2022.
//

import Foundation
import WalletConnectSwift

class TxWorker {
    
    static func construct(from: String,
                          data: String = "",
                          value: String = "0x0",
                          gas: String? = nil,
                          gasPrice: String? = nil) -> Client.Transaction {
        let contractAddress = Constants.TESTING ? Constants.ContractAddress.Testnet :
                                                  Constants.ContractAddress.Mainnet
        return Client.Transaction(from: from,
                                  to: contractAddress,
                                  data: data,
                                  gas: gas,
                                  gasPrice: gasPrice,
                                  value: value,
                                  nonce: nil,
                                  type: nil,
                                  accessList: nil,
                                  chainId: nil,
                                  maxPriorityFeePerGas: nil,
                                  maxFeePerGas: nil)
    }
}
