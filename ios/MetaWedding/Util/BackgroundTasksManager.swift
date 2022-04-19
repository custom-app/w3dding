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
    var certificateBackgroundTaskID: UIBackgroundTaskIdentifier?
    
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
    
    func createCertificateBackgroundTask() {
        certificateBackgroundTaskID =
        UIApplication.shared.beginBackgroundTask (withName: "Upload certificate image") { [weak self] in
            self?.finishCertificateBackgroundTask()
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
    
    func finishCertificateBackgroundTask() {
        if let taskId = certificateBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.certificateBackgroundTaskID = nil
        }
    }
}
