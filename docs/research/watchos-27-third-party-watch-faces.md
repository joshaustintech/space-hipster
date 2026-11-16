# Third-party watch faces on watchOS 27

All sources accessed 2026-11-15. Apple's documentation is the evidence below. Secondary sources are marked **[secondary]** and were only used to find leads.

## Bottom line

You can't ship a true third-party watch face on watchOS 27. Apple publishes no framework, API, or entitlement that lets a developer make a face that appears in the face gallery or replaces the system face. watchOS 27's developer material ([What's new in watchOS 27](https://developer.apple.com/watchos/whats-new/), [watchOS 27 release notes](https://developer.apple.com/documentation/watchos-release-notes/watchos-27-release-notes)) adds no such API. Apple's own docs describe developers as *supplying complications to Apple's faces* and *sharing pre-configured Apple faces*, never as authoring faces ([HIG: Watch faces](https://developer.apple.com/design/human-interface-guidelines/watch-faces), [Sharing an Apple Watch face](https://developer.apple.com/documentation/clockkit/sharing-an-apple-watch-face)).

The closest supported path is:

- **WidgetKit complications** (`accessoryCircular`, `accessoryRectangular`, `accessoryInline`, `accessoryCorner`), which also appear as Smart Stack widgets.
- **A curated `.watchface` file** that pre-configures an Apple face with your complications and is distributed through `CLKWatchFaceLibrary`, your website, or Messages/Mail.
- **Optionally, a full-screen watch app** that supports Always On via `isLuminanceReduced`. It is not a face: it never becomes the system face.

**Confidence:** high that no public API exists. That rests on the absence of any API across all current Apple docs plus positive descriptions of the alternatives. Apple has not published an explicit current "this is not supported" statement; see "Unknown / not found" below.

---

## 1. Is there a public API for third-party watch faces in watchOS 27?

**No.**

- **What's new in watchOS 27:** [Apple's page](https://developer.apple.com/watchos/whats-new/) lists only Foundation Models, Vision, and HealthKit additions. It says nothing about watch faces, complications, or widgets.
- **watchOS 27 SDK release notes:** The face-related entries in [the release notes](https://developer.apple.com/documentation/watchos-release-notes/watchos-27-release-notes) are all bug fixes, not new features:
  - "Some complications might be missing in the Watch app's Face Gallery" (177840928)
  - `WCSession.transferCurrentComplicationUserInfo` not working with WidgetKit complications (113202790)
  - a Smart Stack Now Playing fix
  - an Always On status-bar time fix
- **Point releases:** The [27.2](https://developer.apple.com/documentation/watchos-release-notes/watchos-27_2-release-notes) and [27.3 beta](https://developer.apple.com/documentation/watchos-release-notes/watchos-27_3-release-notes) release notes contain only StoreKit Testing items.
- **ClockKit:** Its abstract is "Display app-specific data on the clock face," which describes data on Apple's face, not a face of your own. ClockKit-based complications are "deprecated in watchOS 10 and later. Use WidgetKit" ([ClockKit](https://developer.apple.com/documentation/clockkit)). The only face-level type is `CLKWatchFaceLibrary`, which *imports an existing `.watchface` file*. A `.watchface` is a configured Apple face, not custom rendering code ([CLKWatchFaceLibrary](https://developer.apple.com/documentation/clockkit/clkwatchfacelibrary)).
- **HIG:** [The Watch faces page](https://developer.apple.com/design/human-interface-guidelines/watch-faces) frames the developer's role only as "Help people discover your app by sharing watch faces that feature your complications." It lists Apple's named faces (Infograph, Meridian, Modular Compact, and others) as the faces you can share.
- **WWDC26 watchOS Group Lab:** In [session 8014](https://developer.apple.com/videos/play/wwdc2026/8014/), Apple engineers discuss widgets "and how they integrate with system spaces like smart stack and watch faces." No custom-face API is announced or discussed. An engineer said "I don't think we have much new guidance for watchOS 27" on widgets.
- **Consumer docs:** [Apple Support: What's new in watchOS 27](https://support.apple.com/guide/watch/whats-new-in-watchos-27-apdb93ea3872/watchos) lists new *Apple* faces (Pride Luminance, Siri Modular) and does not mention third-party faces.
- **App Review Guidelines** (last updated Oct 16, 2026): [the guidelines](https://developer.apple.com/app-store/review/guidelines/) have no clause that mentions "watch face" or "complication." Two clauses still apply to a face-like app:
  - 5.2.5: "Don't create an app that appears confusingly similar to an existing Apple product, interface ... or app"
  - 5.2.5, on Activity rings: an app "should not visualize Move, Exercise, or Stand data in a way that resembles the Activity control"

**Older but explicit statement:** In a watchOS 2-era (2015) forum reply, the answer was "there is not API in watchOS 2 to create a custom watch face," pointing to ClockKit complications instead ([forums thread 7181](https://developer.apple.com/forums/thread/7181)). It is dated, and I could not confirm the replier was Apple staff from the summary I got. Treat it as historical context only.

**Leads that point the same way [secondary]:** [iWatchFaces](https://www.iwatchfaces.com/journal/third-party-apple-watch-faces-explained) says watchOS 27 adds Apple faces but no developer face API. [AppleInsider](https://appleinsider.com/inside/watchos-27) describes a third-party face store as a top user request that Apple hasn't delivered.

## 2. The closest supported paths

### a. WidgetKit complications, the primary path

- **What they are:** Accessory widgets "also appear as watch complications on Apple Watch" and in the Smart Stack. They use WidgetKit and SwiftUI views, so you can share code with iOS Lock Screen widgets ([Creating accessory widgets and watch complications](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications)).
- **Families:** `accessoryCircular`, `accessoryRectangular`, `accessoryInline`, and `accessoryCorner`. The last is "a widget-based complication in the corner of a watch face in watchOS." `WidgetFamily` is available on watchOS 9.0+. The docs show no new families for 27 ([WidgetFamily](https://developer.apple.com/documentation/widgetkit/widgetfamily)).
- **Placement on faces:** Circular appears on Infograph/Infograph Modular, with extra-large layouts on X-Large. Corner appears on faces like Infograph. Rectangular can display "full-color images, text, a gauge, and an optional title" ([HIG: Complications](https://developer.apple.com/design/human-interface-guidelines/complications)).
- **Smart Stack:** Rectangular complications are also supported "as widgets in the Smart Stack" (HIG change log, June 5, 2023).
- **Tinted mode:** The system "desaturates your complication, converting it to grayscale and tinting" it in tinted mode, so "Avoid using color as the only way to communicate important information" (HIG: Complications).
- **Always On privacy:** Information on the face may be visible to others in Always On, so let people hide sensitive data (HIG: Complications).
- **ClockKit migration:** Once you ship a widget-based complication, "the system stops calling ClockKit APIs" (Creating accessory widgets...).
- **Limits:** You control the content inside a slot. You don't control the face's time display, layout, background, or hands. That last part is an inference from the docs above, which only describe slot-level families.

### b. Curated `.watchface` sharing, the closest thing to "shipping a face"

- **What a `.watchface` file is:** It contains "configuration, color, any images it displays, and its complications." When a user adds one, the system "prompts the user to install any missing apps." Apple frames this as a way "to introduce your app to new users" ([Sharing an Apple Watch face](https://developer.apple.com/documentation/clockkit/sharing-an-apple-watch-face)).
- **How you make one:** Build it in the Watch app on iPhone, on Apple Watch, or in the watchOS simulator, then share it. Nothing in the docs creates the file from code.
- **Distribution:**
  - Embed it in your app and install it with `CLKWatchFaceLibrary().addWatchFace(at:completionHandler:)` (iOS 14+/watchOS 7+), only after the user taps an "Add Apple Watch Face" button. Check `WCSession.isPaired` first.
  - Host it on the web with MIME type `application/vnd.apple.watchface`.
  - Send it through Messages or Mail.
- **Requirements:**
  - All complications on the face must come from apps with a valid App Store ID (App Store or TestFlight). Development builds don't qualify.
  - Some faces are device-limited. Nike and Hermès faces only work on those editions, and Infograph and others need Series 4 or later. Handle `addWatchFace` errors and offer a compatible face.
  - The guide is written around ClockKit: `getLocalizableSampleTemplate`, `handleSharedComplicationDescriptors`, and `CLKDefaultComplicationTypeIdentifier`. Check how WidgetKit-only complications behave in shared faces with a TestFlight build. The docs I read didn't spell out the WidgetKit equivalent.
- **Known issues reported on Apple's forums:**
  - **Sharing broke on watchOS 26 (Dec 2025):** A developer reported that sharing stopped working through `CLKWatchFaceLibrary` and iMessage, affecting apps like Facer. Apple DTS only asked for a feedback ID, with no fix confirmed ([thread 811587](https://developer.apple.com/forums/thread/811587)). I found nothing confirming whether this is fixed in watchOS 27, so test it.
  - **Wrong complication labels (Nov 2025):** The Watch app shows wrong complication names after applying a `.watchface` that uses WidgetKit/AppIntent complications. DTS said "it does sound like an issue on the Watch app in iOS" (FB20915258) ([thread 806152](https://developer.apple.com/forums/thread/806152)). This thread also shows `.watchface` sharing works with WidgetKit complications.

### c. Smart Stack widgets

- **Relevance:** Use the Widget Relevance API, "which is heavily exercised on watchOS" (WWDC26 Group Lab, [session 8014](https://developer.apple.com/videos/play/wwdc2026/8014/)).
- **Siri Modular face (watchOS 27):** It "displays the top Smart Stack widget for that moment and surfaces other widgets as you turn the Digital Crown" ([Apple Support: faces and features](https://support.apple.com/guide/watch/faces-and-features-apde9218b440/watchos)). So a good Smart Stack widget can sit at the center of an Apple face. I took this quote from a search-result summary of that Support page and did not re-fetch the page itself.

### d. Photos / Portraits faces

The docs don't offer a developer API for these, and none of the pages I read mention one.

## 3. watchOS 27-specific changes that matter here

- **New Apple faces:** Pride Luminance and Siri Modular are Apple-made, not developer APIs ([Apple Support: What's new in watchOS 27](https://support.apple.com/guide/watch/whats-new-in-watchos-27-apdb93ea3872/watchos)).
- **New Smart Stack tap gesture:** "perform the single tap gesture to select a widget" ([Apple Support: What's new in watchOS 27](https://support.apple.com/guide/watch/whats-new-in-watchos-27-apdb93ea3872/watchos)).
- **Widget updates through Watch Connectivity:** "being able to update widgets with watch connectivity ... it works now" (Group Lab, [8014](https://developer.apple.com/videos/play/wwdc2026/8014/)). This matches the release-note fix for `transferCurrentComplicationUserInfo` with WidgetKit complications ([release notes](https://developer.apple.com/documentation/watchos-release-notes/watchos-27-release-notes)). watchOS 26 added APNs-based widget refreshes (same session).
- **Widget performance and refresh budget:** Apple says there are general performance and reliability improvements for widgets. Things on the watch face are "at the top tier of the budget," and actively used widgets can expect updates "every 15 to 20 minutes" (Group Lab, 8014). These are engineer remarks in a lab, not documented guarantees.
- **New on-watch frameworks:** Foundation Models and Vision, which could power complication content ([What's new in watchOS 27](https://developer.apple.com/watchos/whats-new/)).
- **Beta complication bug:** A watchOS 27 beta bug blanked WidgetKit complications after every app update. The reporter says it was fixed in watchOS 27.0 (24R364), but Apple has not confirmed this ([thread 844423](https://developer.apple.com/forums/thread/844423)).

## 4. What happens to a SwiftUI watch-face prototype

**Can be reused:**

- **Complication views:** SwiftUI views are the complication view layer. Split the prototype into glanceable pieces and render each one inside a widget family:
  - a ring or gauge goes in `accessoryCircular` or `accessoryCorner`
  - a status panel goes in `accessoryRectangular`
  - a one-line readout goes in `accessoryInline`

  This works because complications are built "using SwiftUI views and WidgetKit" ([Creating accessory widgets...](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications)). Each view must work in tinted mode ([HIG: Complications](https://developer.apple.com/design/human-interface-guidelines/complications)).
- **A full-screen app with Always On:** The whole prototype can ship as a watch app screen:
  - Read `@Environment(\.isLuminanceReduced)` (watchOS 8+) to dim the UI on wrist-down, for example by switching filled shapes to strokes.
  - Since watchOS 8, the system "keeps your view visible on wrist down by default." To opt out, set `WKSupportsAlwaysOnDisplay` to `false` ([isLuminanceReduced](https://developer.apple.com/documentation/swiftui/environmentvalues/isluminancereduced)).
  - For per-second or per-minute updates, `TimelineView` is the usual SwiftUI tool. I did not fetch its Always On cadence documentation, so check it before relying on second-hand updates while dimmed.
- **A marketing `.watchface`:** Place your complications on the Apple face that best matches the prototype's look (for example Modular Duo or Infograph) and ship it as a `.watchface` file ([Sharing an Apple Watch face](https://developer.apple.com/documentation/clockkit/sharing-an-apple-watch-face)).

**Cannot be reused as-is:**

- **The face itself:** No API makes your own time display, background, hands, or layout the system face, or puts it in the face gallery (section 1).
- **App-only behavior inside complications:** Interactivity, animation, and continuous updates are subject to WidgetKit's timeline/refresh model and budget (Group Lab remarks above). A live-ticking custom design won't behave the same in a complication.
- **An app as a face replacement:** The app isn't the face. Apple's docs describe no supported way for an app to stay frontmost in place of the face, so treat it as a destination people open, not a face replacement. That is an inference: I found no Apple doc granting this, and didn't find an explicit prohibition either.
- **Look-alikes:** Designs that copy Apple's system UI or the Activity rings risk rejection under App Review 5.2.5 ([guidelines](https://developer.apple.com/app-store/review/guidelines/)).

## Recommended path for this project

1. **Reframe the deliverable:** Ship "a set of complications plus a curated face," not "a watch face." Move the prototype's signature elements into a WidgetKit extension that supports `accessoryCircular`, `accessoryCorner`, `accessoryRectangular`, and `accessoryInline`. Design for full-color and tinted modes, and hide sensitive data in Always On.
2. **Ship `.watchface` presets:** Build one or two Apple faces featuring those complications, plus a fallback face for older or other hardware. Offer them from the iOS app through `CLKWatchFaceLibrary` behind an "Add Apple Watch Face" button, and on the web. Test with a TestFlight build: dev builds don't count, and sharing had reported issues on watchOS 26.
3. **Make the rectangular widget Smart Stack-worthy:** Add relevance signals so it surfaces on Siri Modular and in the Smart Stack.
4. **Keep the full prototype as the app's main screen:** Support Always On through `isLuminanceReduced`.
5. **Avoid copying Apple's look:** Don't imitate Apple system faces or Activity rings (5.2.5).

## Unknown / not found

- **No current Apple statement that custom faces are unsupported:** The only explicit statement is the 2015 forum reply, and I could not confirm the replier was Apple staff. The current conclusion rests on what the docs leave out.
- **Whether watchOS 27 fixes the watchOS 26 `.watchface` sharing break:** Unconfirmed.
- **The WidgetKit-native version of the ClockKit-centric sharing guide:** The sharing guide relies on `getLocalizableSampleTemplate` and `handleSharedComplicationDescriptors`. I did not find Apple's documented WidgetKit equivalents.
- **The full WWDC26 session list:** I couldn't get it. The videos index page I fetched showed no watchOS-specific sessions beyond the Group Lab (8014), so a dedicated watchOS widget session may exist and I missed it.
- **Apple Newsroom's watchOS 27 announcement:** Not found. I used secondary coverage only to find leads, and it is not relied on above.

## Sources (accessed 2026-11-15)

- What's new in watchOS 27: https://developer.apple.com/watchos/whats-new/
- watchOS 27 Release Notes: https://developer.apple.com/documentation/watchos-release-notes/watchos-27-release-notes
- watchOS 27.2 Release Notes: https://developer.apple.com/documentation/watchos-release-notes/watchos-27_2-release-notes
- watchOS 27.3 Beta Release Notes: https://developer.apple.com/documentation/watchos-release-notes/watchos-27_3-release-notes
- ClockKit: https://developer.apple.com/documentation/clockkit
- CLKWatchFaceLibrary: https://developer.apple.com/documentation/clockkit/clkwatchfacelibrary
- Sharing an Apple Watch face: https://developer.apple.com/documentation/clockkit/sharing-an-apple-watch-face
- Creating accessory widgets and watch complications: https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications
- WidgetFamily: https://developer.apple.com/documentation/widgetkit/widgetfamily
- isLuminanceReduced: https://developer.apple.com/documentation/swiftui/environmentvalues/isluminancereduced
- HIG: Watch faces: https://developer.apple.com/design/human-interface-guidelines/watch-faces
- HIG: Complications: https://developer.apple.com/design/human-interface-guidelines/complications
- App Review Guidelines (updated Oct 16, 2026): https://developer.apple.com/app-store/review/guidelines/
- WWDC26 watchOS Group Lab (8014): https://developer.apple.com/videos/play/wwdc2026/8014/
- Forums thread 811587 (sharing broken on watchOS 26): https://developer.apple.com/forums/thread/811587
- Forums thread 806152 (.watchface labels, DTS reply): https://developer.apple.com/forums/thread/806152
- Forums thread 844423 (watchOS 27 beta complications bug): https://developer.apple.com/forums/thread/844423
- Forums thread 7181 (2015, no custom face API): https://developer.apple.com/forums/thread/7181
- Apple Support, What's new in watchOS 27: https://support.apple.com/guide/watch/whats-new-in-watchos-27-apdb93ea3872/watchos
- Apple Support, Faces and features: https://support.apple.com/guide/watch/faces-and-features-apde9218b440/watchos
- [secondary, leads only] iWatchFaces: https://www.iwatchfaces.com/journal/third-party-apple-watch-faces-explained
- [secondary, leads only] AppleInsider watchOS 27: https://appleinsider.com/inside/watchos-27
