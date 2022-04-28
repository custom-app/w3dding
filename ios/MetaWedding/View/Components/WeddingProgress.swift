//
//  WeddingProgress.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.04.2022.
//

import SwiftUI

struct WeddingProgress: View {
    
    @State
    var angle: Double = 0.0
    @State
    var isAnimating = false
    
    let size: Double = 60
    
    var foreverAnimation: Animation {
        Animation.easeInOut(duration: 1.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image("ic_logo_single")
            .resizable()
            .scaledToFit()
            .frame(width: size)
            .rotationEffect(Angle(degrees: isAnimating ? 360.0 : 0.0))
            .animation(foreverAnimation)
            .onAppear {
                isAnimating = true
            }
    }
}

struct WeddingProgress_Previews: PreviewProvider {
    static var previews: some View {
        WeddingProgress()
    }
}
