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
                          gasPrice: String? = nil) -> Client.Transaction {
        let contractAddress = Config.TESTING ? Constants.WeddingContract.Testnet :
                                                  Constants.WeddingContract.Mainnet
        return Client.Transaction(from: from,
                                  to: contractAddress,
                                  data: data,
                                  gas: nil,
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
