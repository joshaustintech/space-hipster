// Draft. Not compiled or run. Check every API against Apple's docs (see docs/watchos-notes.md).
import SwiftUI

extension Color {
    /// Hex like 0xA8D8F5.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

public enum SH {
    public enum Palette {
        public static let ground = Color(hex: 0x000000)
        public static let crater = Color(hex: 0x1C1D21)
        public static let shale = Color(hex: 0x2B2D33)
        public static let dust = Color(hex: 0x8E9097)      // non-text only
        public static let heather = Color(hex: 0xC8CACF)   // secondary text
        public static let sail = Color(hex: 0xF2F1EC)      // primary text
        public static let ice = Color(hex: 0xA8D8F5)       // primary action
        public static let icePressed = Color(hex: 0x8CC4E8)
        public static let volt = Color(hex: 0xD0FF3F)      // success, focus
        public static let orange = Color(hex: 0xFF5F1F)    // warning, destructive
        public static let violet = Color(hex: 0xA99BFF)
        public static let speckTeal = Color(hex: 0x5EE6D0)
        public static let speckYellow = Color(hex: 0xFFD966)

        /// Colors allowed for watch-face digits on black. All pass 4.5:1 on black.
        public static let faceDigits: [Color] = [ice, volt, orange, violet, speckTeal, speckYellow, sail]
    }

    public enum Spacing {
        public static let s1: CGFloat = 4
        public static let s2: CGFloat = 8
        public static let s3: CGFloat = 12
        public static let s4: CGFloat = 16
        public static let s6: CGFloat = 24
    }

    public enum Control {
        public static let minimum: CGFloat = 44
    }

    public enum Face {
        public static let widthPercentRange = 75.0...125.0   // map to Font.Width's scale; mapping unconfirmed
        public static let weightValues = [400, 500, 600, 700, 800, 900]
        public static let animationDuration: Double = 1.5     // 1500 ms
        public static let complicationSlot: CGFloat = 44
    }

    /// Style for one character on the face. No two characters share weight, width or color.
    public struct CharacterStyle {
        public let character: Character
        public let widthPercent: Double
        public let weight: Int
        public let color: Color
    }

    /// Draws unique styles for the five characters of "12:34"-style text.
    /// Callers pass the characters to style. Requires 5 or fewer distinct values per attribute.
    public static func randomStyles(for characters: [Character]) -> [CharacterStyle] {
        precondition(characters.count <= Face.weightValues.count)
        let widths = Array(stride(from: 75.0, through: 125.0, by: 5.0)).shuffled()
        let weights = Face.weightValues.shuffled()
        let colors = Palette.faceDigits.shuffled()
        return characters.enumerated().map { i, ch in
            CharacterStyle(character: ch, widthPercent: widths[i], weight: weights[i], color: colors[i])
        }
    }
}
