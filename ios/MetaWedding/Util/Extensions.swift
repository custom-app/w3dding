//
//  Extensions.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 07.04.2022.
//

import Foundation
import BigInt
import SwiftUI

extension BigUInt {
    func toHexString() -> String {
        String(self, radix: 16, uppercase: true)
    }
}

extension Date {
    
    init(timestamp: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
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

extension Color {
    init(hex: String) {
        let hex = hex.uppercased().trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIImage {
    func base64() -> String? {
        self.pngData()?.base64EncodedString()
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
