// PROTOTYPE — the three variants. Shared: black ground, four 44 pt complication slots, time in the
// middle band. Each variant disagrees about size, alignment, and how width is rendered.
import SwiftUI

struct FaceScreen: View {
    let variant: Variant
    @ObservedObject var model: FaceModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isLuminanceReduced) private var luminanceReduced
    @State private var showState = false

    private let slot = SH.Face.complicationSlot
    private let inset: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let bandTop = inset + slot + SH.Spacing.s1
            let bandHeight = h - 2 * bandTop
            ZStack {
                Color.black
                slots(w: w, h: h)
                time(w: w, bandHeight: bandHeight)
                    .frame(width: w - 2 * (variant == .A ? 0 : SH.Spacing.s4), height: bandHeight, alignment: alignment)
                    .frame(width: w, height: h)
                    .overlay {
                        // Prototype guide: the middle band the time must stay inside.
                        Rectangle().stroke(Color.red.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                            .frame(width: w, height: bandHeight)
                            .allowsHitTesting(false)
                    }
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            model.redraw()
            model.playShift(reduceMotion: reduceMotion)
        }
        .onLongPressGesture { showState = true }
        .sheet(isPresented: $showState) { stateSheet }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Date.now, style: .time))
    }

    private var alignment: Alignment {
        switch variant {
        case .A: .center
        case .B: .leading
        case .C: .trailing
        }
    }

    private var hAlign: HorizontalAlignment {
        switch variant {
        case .A: .center
        case .B: .leading
        case .C: .trailing
        }
    }

    private func fontSize(w: CGFloat, bandHeight: CGFloat) -> CGFloat {
        switch variant {
        case .A: w * 64 / 240                 // canvas board: 64 px in a 240 px frame
        case .B: bandHeight / 2 / 0.80        // two lines, tight leading, fill the band
        case .C: w * 64 / 240 * 1.12
        }
    }

    @ViewBuilder
    private func time(w: CGFloat, bandHeight: CGFloat) -> some View {
        let size = fontSize(w: w, bandHeight: bandHeight)
        let chars = model.characters
        let split = model.hour.count
        let lineGap = -size * (variant == .B ? 0.32 : 0.22)
        VStack(alignment: hAlign, spacing: lineGap) {
            line(chars, 0..<split, size: size)
            line(chars, split..<chars.count, size: size)
        }
        .minimumScaleFactor(0.5)
        .opacity(luminanceReduced ? 0.9 : 1)
    }

    private func line(_ chars: [Character], _ range: Range<Int>, size: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(range), id: \.self) { i in
                if i < model.draws.count, i < model.shownWidths.count {
                    Glyph(character: chars[i], widthPercent: model.shownWidths[i], draw: model.draws[i],
                          size: size, useScale: variant == .C)
                }
            }
        }
    }

    private func slots(w: CGFloat, h: CGFloat) -> some View {
        let r = slot / 2
        let points = [CGPoint(x: inset + r + 6, y: inset + r), CGPoint(x: w - inset - r - 6, y: inset + r),
                      CGPoint(x: inset + r + 6, y: h - inset - r), CGPoint(x: w - inset - r - 6, y: h - inset - r)]
        return ZStack {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .strokeBorder(SH.Palette.dust, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    .frame(width: slot, height: slot)
                    .position(points[i])
            }
        }
        .opacity(luminanceReduced ? 0.55 : 1)
        .accessibilityHidden(true)
    }

    private var stateSheet: some View {
        let chars = model.characters
        return List {
            Text("\(variant.rawValue) · \(variant.name)").font(.headline)
            ForEach(Array(model.draws.prefix(chars.count).enumerated()), id: \.offset) { i, d in
                HStack {
                    Text(String(chars[i])).foregroundStyle(Color(hex: d.colorHex)).bold()
                    Spacer()
                    Text("w\(Int(d.widthPercent)) · \(d.weight) · #\(String(d.colorHex, radix: 16, uppercase: true))")
                        .font(.system(size: 12, design: .monospaced))
                }
            }
        }
    }
}
