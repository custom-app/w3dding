//
//  OnboardingContainer.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.05.2022.
//

import SwiftUI

struct OnboardingContainer: View {
    
    @StateObject
    var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            if onboardingViewModel.soundSelected {
                OnboardingScreen()
            } else {
                OnboardingSoundScreen()
            }
        }
        .environmentObject(onboardingViewModel)
    }
}

struct OnboardingContainer_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainer()
    }
}
