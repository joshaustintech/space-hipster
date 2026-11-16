// PROTOTYPE — throwaway. Question: what should the Space Hipster face look like on a real watch screen?
// Three variants of the face, switchable by swiping left/right (or launch arg `-variant B`).
// Tap the face to redraw styles + replay the 1500 ms width shift. Long-press to see the current draw.
// Launch arg `-fakeTime 12:34` pins the time to match the canvas board.
import SwiftUI

@main
struct SpaceHipsterFacePrototypeApp: App {
    var body: some Scene {
        WindowGroup { if UserDefaults.standard.bool(forKey: "widthTest") { WidthTest() } else { PrototypeSwitcher() } }
    }
}

enum Variant: String, CaseIterable, Identifiable {
    case A, B, C
    var id: String { rawValue }
    var name: String {
        switch self {
        case .A: "Canvas"
        case .B: "Fill band"
        case .C: "Scaled glyphs"
        }
    }
}

/// Prototype-only switcher: horizontal paging between variants, with a high-contrast pill that
/// names the variant for 1.5 s after every switch. Not part of the design being evaluated.
struct PrototypeSwitcher: View {
    @State private var variant: Variant =
        Variant(rawValue: UserDefaults.standard.string(forKey: "variant") ?? "A") ?? .A
    @State private var showPill = true
    @StateObject private var model = FaceModel()

    var body: some View {
        TabView(selection: $variant) {
            ForEach(Variant.allCases) { v in
                FaceScreen(variant: v, model: model).tag(v)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.black)
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .overlay(alignment: .center) {
            #if DEBUG
            if showPill {
                Text("◀ \(variant.rawValue) · \(variant.name) ▶")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(Color.white))
                    .shadow(radius: 4)
                    .offset(y: 70)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
            #endif
        }
        .onAppear { flashPill() }
        .onChange(of: variant) { flashPill(); print("[prototype] variant=\(variant.rawValue) \(variant.name)") }
    }

    private func flashPill() {
        withAnimation { showPill = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showPill = false } }
    }
}
