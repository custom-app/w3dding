//
//  Extensions.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 07.04.2022.
//

import Foundation
import BigInt

extension BigUInt {
    func toHexString() -> String {
        String(self, radix: 16, uppercase: true)
    }
}

