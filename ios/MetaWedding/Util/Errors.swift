//
//  Errors.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 04.04.2022.
//

import Foundation

enum InnerError: Error {
    case balanceParseError
    case invalidAddress
}

class Errors {
    static let userCanceled = "User canceled"
    static let unknownError = "Unknown error happened. Pleasy check your internet connection and try again"
    static let failedToConnect = "Failed to connect to wallet app. Please try again"
    static let getGasPrice = "Get gas price failed. Please try again"
    
    static func messageFor(err: String) -> String {
        switch err {
        case userCanceled:
            return "Request was denied"
        case failedToConnect:
            return failedToConnect
        case getGasPrice:
            return getGasPrice
        case unknownError:
            return unknownError
        default:
            return unknownError
        }
    }
}
