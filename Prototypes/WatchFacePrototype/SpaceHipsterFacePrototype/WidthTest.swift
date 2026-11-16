// PROTOTYPE — launch with `-widthTest YES` to check whether Font.Width does anything on the watch.
import SwiftUI

struct WidthTest: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach([Font.Design.rounded, .default], id: \.self) { design in
                Text(design == .rounded ? "rounded, numeric 75/100/125" : "default, numeric").font(.caption2).foregroundStyle(.gray)
                HStack(spacing: 4) {
                    ForEach([75.0, 100.0, 125.0], id: \.self) { p in
                        Text("00").font(.system(size: 30, weight: .bold, design: design).width(shWidth(percent: p)))
                            .foregroundStyle(.white).background(Color.red.opacity(0.3))
                    }
                }
            }
            Text("default, named compr/std/expd").font(.caption2).foregroundStyle(.gray)
            HStack(spacing: 4) {
                ForEach([Font.Width.compressed, .standard, .expanded], id: \.self) { w in
                    Text("00").font(.system(size: 30, weight: .bold).width(w))
                        .foregroundStyle(.white).background(Color.red.opacity(0.3))
                }
            }
        }
    }
}
