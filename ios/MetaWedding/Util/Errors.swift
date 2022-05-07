//
//  Errors.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 04.04.2022.
//

import Foundation

enum InnerError: Error {
    case balanceParseError
    case invalidAddress(address: String)
    case structParseError(description: String)
    case unsuccessfullСontractRead(description: String)
    case storeUploadParseError(description: String)
    case nilDataError
    case httpError(body: String)
    case nilContractMethodData(method: String)
    case nilClientOrSession
    case nilCertificateUrl
    case jpegConverting
    case nilJpegData
}

class Errors {
    static let userCanceled = "User canceled"
    static let userRejected = "User rejected the transaction"
    static let unknownError = "Unknown error happened. Please check your internet connection and try again"
    static let failedToConnect = "Failed to connect to wallet app. Please try again"
    static let getGasPrice = "Get gas price failed. Please try again"
    
    static func messageFor(err: String) -> String {
        switch err {
        case userCanceled, userRejected:
            return "Request was denied"
        case failedToConnect:
            return failedToConnect
        case getGasPrice:
            return getGasPrice
        default:
            return unknownError
        }
    }
}
