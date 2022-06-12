//
//  UserDefaultsWorker.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 21.05.2022.
//

import Foundation

class UserDefaultsWorker {
    static let shared = UserDefaultsWorker()
    
    private static let OnboardingShownKey = "onboarding_shown"

    func isOnboardingShown() -> Bool? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: UserDefaultsWorker.OnboardingShownKey) as? Bool
    }

    func setOnBoardingShown(shown: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(shown, forKey: UserDefaultsWorker.OnboardingShownKey)
    }
}
