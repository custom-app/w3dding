//
//  BackgroundTasksWorker.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 20.04.2022.
//

import Foundation
import UIKit

class BackgroundTasksManager {
    
    var connectBackgroundTaskID: UIBackgroundTaskIdentifier?
    var sendTxBackgroundTaskID: UIBackgroundTaskIdentifier?
    var newProposalBackgroundTaskID: UIBackgroundTaskIdentifier?
    
    func createConnectBackgroundTask() {
        connectBackgroundTaskID =
        UIApplication.shared.beginBackgroundTask (withName: "Connect to wallet connect") { [weak self] in
            self?.finishConnectBackgroundTask()
        }
    }
    
    func createSendTxBackgroundTask() {
        sendTxBackgroundTaskID =
        UIApplication.shared.beginBackgroundTask (withName: "Send tx") { [weak self] in
            self?.finishSendTxBackgroundTask()
        }
    }
    
    func createProposalBackgroundTask() {
        newProposalBackgroundTaskID =
        UIApplication.shared.beginBackgroundTask (withName: "Upload proposal info") { [weak self] in
            self?.finishProposalBackgroundTask()
        }
    }
    
    func finishConnectBackgroundTask() {
        if let taskId = connectBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.connectBackgroundTaskID = nil
        }
    }
    
    func finishSendTxBackgroundTask() {
        if let taskId = sendTxBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.sendTxBackgroundTaskID = nil
        }
    }
    
    func finishProposalBackgroundTask() {
        if let taskId = newProposalBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.newProposalBackgroundTaskID = nil
        }
    }
}
