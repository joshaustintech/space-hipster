# PROTOTYPE: Space Hipster face on watchOS 27.2 (throwaway)

**Question:** what should the Space Hipster face (CLAUDE.md, `design/canvas/Watchfaces.dc.html`) look like on a real watch screen?

Run: `./run.sh [A|B|C] [HH:MM]`. Example: `./run.sh C 12:34`. Swipe left/right to switch variants. Tap to redraw styles and replay the 1500 ms width shift. Long-press to list the current draw. `./run.sh widthtest` shows the Font.Width check.

| Variant | Layout | Width rendering |
|---|---|---|
| A · Canvas | Centered, size scaled from the board (64 px in a 240 px frame) | `Font.Width` |
| B · Fill band | Leading, 16 pt margin, as large as the middle band allows | `Font.Width` |
| C · Scaled glyphs | Trailing, 112 % of A | `scaleEffect(x:)` on standard width |

## Findings (watchOS 27.2 simulator, Series 12 46 mm, Xcode 27.2)

1. **`Font.Width` does nothing on watchOS.** Numeric (−0.2/0/+0.2) and named (`.compressed/.standard/.expanded`) widths render identically, in both the rounded and default designs. So A and B only vary weight and color. To get width variation, fake it with horizontal scaling (C) or a custom font.
2. **The system clock sits on the top-right complication slot** in an app. `.persistentSystemOverlays(.hidden)` does not hide it. An app version of this face loses that corner or has to live with the clock there.
3. On macOS, `Font.Width` values are compressed −0.3, condensed −0.2, standard 0, expanded +0.2. Mapping used: `(percent − 100) / 125`, so 75 % → −0.2 and 125 % → +0.2.
4. `SpaceHipsterTokens.swift` (copied from the untracked design files) compiles for watchOS unchanged.
5. Not checked: whether third-party watch faces are possible on watchOS 27, the open decision on redraw cadence (the prototype keeps styles across minutes and redraws on tap), Always On on device, and Low Power Mode behavior.
