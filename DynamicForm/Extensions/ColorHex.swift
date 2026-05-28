import Foundation
import SwiftUI

extension Color {
    init(hex: String?, fallback: Color) {
        guard let hex else {
            self = fallback
            return
        }

        let trimmedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0

        guard Scanner(string: trimmedHex).scanHexInt64(&value) else {
            self = fallback
            return
        }

        switch trimmedHex.count {
        case 6:
            let red = Double((value & 0xFF0000) >> 16) / 255.0
            let green = Double((value & 0x00FF00) >> 8) / 255.0
            let blue = Double(value & 0x0000FF) / 255.0
            self = Color(red: red, green: green, blue: blue)
        case 8:
            let alpha = Double((value & 0xFF000000) >> 24) / 255.0
            let red = Double((value & 0x00FF0000) >> 16) / 255.0
            let green = Double((value & 0x0000FF00) >> 8) / 255.0
            let blue = Double(value & 0x000000FF) / 255.0
            self = Color(red: red, green: green, blue: blue, opacity: alpha)
        default:
            self = fallback
        }
    }
}
