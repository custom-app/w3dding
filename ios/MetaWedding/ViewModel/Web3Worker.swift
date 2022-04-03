//
//  Web3.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 04.04.2022.
//

import Foundation

class Web3Worker:  ObservableObject {
    
    let endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
}
