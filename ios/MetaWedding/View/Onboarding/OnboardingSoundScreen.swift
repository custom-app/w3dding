//
//  OnboardingSounScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.05.2022.
//

import SwiftUI

struct OnboardingSoundScreen: View {
    
    @EnvironmentObject
    var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            Image("DefaultBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                Image("ic_sound")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 62)
                
                Text("Music will not disturb you?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Colors.darkPurple)
                    .padding(.top, 24)
                
                HStack(spacing: 0) {
                    Spacer()
                    Button {
                        onboardingViewModel.soundOn = false
                        withAnimation {
                            onboardingViewModel.soundSelected = true
                        }
                    } label: {
                        Text("Sound Off")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(Colors.purple)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Colors.purple, lineWidth: 2)
                            )
                    }
                    Button {
                        onboardingViewModel.soundOn = true
                        withAnimation {
                            onboardingViewModel.soundSelected = true
                        }
                        onboardingViewModel.startMusic()
                    } label: {
                        Text("Sound On")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 29)
                            .padding(.vertical, 16)
                            .background(Colors.purple)
                            .cornerRadius(32)
                    }
                    .padding(.leading, 24)
                    Spacer()
                }
                .padding(.top, 24)
                Spacer()
            }
            
            
        }
    }
}

struct OnboardingSounScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSoundScreen()
    }
}
