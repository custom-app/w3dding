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

extension Date {
    func formattedDateString(_ format: String? = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func dayOrdinal() -> String {
        let calendar = Calendar.current
        let dayComponent = calendar.component(.day, from: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale =  Locale(identifier: "en_US")
//        numberFormatter.numberStyle = .spellOut
        numberFormatter.numberStyle = .ordinal
        let day = numberFormatter.string(from: dayComponent as NSNumber)
        return day!
    }
}
