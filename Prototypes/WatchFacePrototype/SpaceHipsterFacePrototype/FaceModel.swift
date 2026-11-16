// PROTOTYPE — shared state for all variants: the current time string, the per-character draw,
// and the animated widths. Variants only decide how to lay it out.
import SwiftUI
import Combine

struct Draw: Equatable {
    var widthPercent: Double   // 75...125
    var weight: Int            // 400...900
    var colorHex: UInt32
}

let digitHexes: [UInt32] = [0xA8D8F5, 0xD0FF3F, 0xFF5F1F, 0xA99BFF, 0x5EE6D0, 0xFFD966, 0xF2F1EC]

@MainActor
final class FaceModel: ObservableObject {
    @Published var hour = "12"
    @Published var minute = ":34"
    @Published var draws: [Draw] = []
    /// What the glyphs are drawn at right now; animates toward draws[i].widthPercent.
    @Published var shownWidths: [Double] = []

    private var timer: AnyCancellable?
    private let fakeTime = UserDefaults.standard.string(forKey: "fakeTime")

    init() {
        redraw()
        shownWidths = draws.map(\.widthPercent)
        tick()
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in self?.tick() }
    }

    var characters: [Character] { Array(hour + minute) }

    /// Unique width, weight and color per character, drawn from the token ranges.
    func redraw() {
        let widths = Array(stride(from: 75.0, through: 125.0, by: 5.0)).shuffled()
        let weights = SH.Face.weightValues.shuffled()
        let colors = digitHexes.shuffled()
        draws = (0..<5).map { Draw(widthPercent: widths[$0], weight: weights[$0], colorHex: colors[$0]) }
        logState("redraw")
    }

    private func tick() {
        let (h, m): (String, String)
        if let fakeTime, let colon = fakeTime.firstIndex(of: ":") {
            (h, m) = (String(fakeTime[..<colon]), String(fakeTime[colon...]))
        } else {
            let c = Calendar.current.dateComponents([.hour, .minute], from: .now)
            let h12 = (c.hour ?? 0) % 12 == 0 ? 12 : (c.hour ?? 0) % 12
            (h, m) = ("\(h12)", String(format: ":%02d", c.minute ?? 0))
        }
        guard h != hour || m != minute else { return }
        hour = h; minute = m
        playShift()
    }

    /// 1500 ms shift: narrow characters start wide and settle narrow, and vice versa.
    /// Skipped under Reduce Motion or Low Power Mode.
    func playShift(reduceMotion: Bool = false) {
        let targets = draws.map(\.widthPercent)
        if reduceMotion || ProcessInfo.processInfo.isLowPowerModeEnabled {
            shownWidths = targets
            return
        }
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { shownWidths = targets.map { 200 - $0 } }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: SH.Face.animationDuration)) { self.shownWidths = targets }
        }
    }

    func logState(_ why: String) {
        let chars = Array("12:34")
        let rows = draws.enumerated().map { i, d in
            "\(i < chars.count ? chars[i] : "?") w\(Int(d.widthPercent))% wt\(d.weight) #\(String(d.colorHex, radix: 16, uppercase: true))"
        }
        print("[prototype] \(why): " + rows.joined(separator: " | "))
    }
}

extension Font.Weight {
    init(cssWeight: Int) {
        switch cssWeight {
        case ..<450: self = .regular
        case ..<550: self = .medium
        case ..<650: self = .semibold
        case ..<750: self = .bold
        case ..<850: self = .heavy
        default: self = .black
        }
    }
}

/// Canvas percent → Font.Width. Measured on macOS: compressed −0.3, condensed −0.2, standard 0, expanded 0.2.
/// Maps 75 % → −0.2 (condensed) and 125 % → +0.2 (expanded), like CSS font-stretch.
func shWidth(percent: Double) -> Font.Width { Font.Width((percent - 100) / 125) }

/// One character. Animatable over its width so the 1500 ms shift interpolates per frame.
struct Glyph: View, Animatable {
    var character: Character
    var widthPercent: Double
    var draw: Draw
    var size: CGFloat
    /// false: real Font.Width axis. true: standard width, squashed/stretched with scaleEffect.
    var useScale = false

    var animatableData: Double {
        get { widthPercent }
        set { widthPercent = newValue }
    }

    var body: some View {
        let base = Text(String(character)).foregroundStyle(Color(hex: draw.colorHex))
        if useScale {
            base.font(.system(size: size, weight: Font.Weight(cssWeight: draw.weight), design: .rounded))
                .fixedSize()
                .scaleEffect(x: widthPercent / 100, y: 1)
                .frame(width: size * (character == ":" ? 0.32 : 0.62) * widthPercent / 100)
        } else {
            base.font(.system(size: size, weight: Font.Weight(cssWeight: draw.weight), design: .rounded)
                .width(shWidth(percent: widthPercent)))
                .fixedSize()
        }
    }
}
