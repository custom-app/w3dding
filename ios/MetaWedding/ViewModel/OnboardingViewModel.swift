//
//  OnboardingViewModel.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 21.05.2022.
//

import Foundation
import SwiftUI
import AVFoundation

class OnboardingViewModel: ObservableObject {
    
    @Published
    var soundSelected = false
    
    @Published
    var soundOn = false
    
    var player: AVAudioPlayer?
    
    func startMusic() {
        guard let path = Bundle.main.path(forResource: "w3dding-sound", ofType:"mp3") else {
            return
        }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopMusic() {
        player?.stop()
    }
    
}
