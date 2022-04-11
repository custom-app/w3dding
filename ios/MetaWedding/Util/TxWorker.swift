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
                          value: String = "0x00",
                          gas: String? = nil,
                          gasPrice: String? = nil) -> Client.Transaction {
        return Client.Transaction(from: from,
                                  to: Constants.ContractAddress.Mainnet,
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
