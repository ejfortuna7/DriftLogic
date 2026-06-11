# DriftLogic iOS — Build & Ship Guide

The app was rebuilt (June 11, 2026) to match the live rockyriversteelhead.com tool: 4 species × 3 methods, 5 picks + 5 videos per result, shop links, live USGS conditions, and a 4,860-scenario golden-master test suite.

## 1. Regenerate the Xcode project

The project is defined by `project.yml` (XcodeGen). After the restructure you must regenerate:

```bash
cd ~/Desktop/DriftLogic
xcodegen            # if missing: brew install xcodegen
open DriftLogic.xcodeproj
```

## 2. Build & test

In Xcode, select an iPhone simulator, then **Cmd+B** to build and **Cmd+U** to run the test suite. The `GoldenMasterTests` compare the Swift engine against `DriftLogicTests/golden.json` — the exact output of the verified web engine for all 4,860 condition combinations. All tests passing = the app's logic is provably identical to the site's.

If the build surfaces small Swift errors (the port was written without a compiler available), they'll be localized — fix or ask Claude to fix from the error list.

## 3. What's where

| Path | Contents |
|---|---|
| `DriftLogic/Engine/` | `DriftLogicCore.swift` (types), `RigEngine.swift` (full decision engine), `VideoLibrary.swift` (69 labeled videos), `ShopLinks.swift` (Amazon + FishUSA + Bass Pro builders) |
| `DriftLogic/Views/` | `ContentView` (chips + flow), `ResultsView`, `VideoSectionView`, `NowCastBanner`, `ConditionChipGrid` |
| `DriftLogic/Services/` | `NowCastService.swift` — live USGS gauge 04201500 (Rocky River) |
| `DriftLogicTests/` | Golden-master + domain-rule tests |
| `Legacy/` | The old fly-only app source (kept for reference, not compiled) |

Intentional divergences from the web engine (both documented in code/tests): HTML entities are decoded to real Unicode, and the web's `current: still` "undefined" text bug is fixed with real copy.

## 4. Run on your iPhone

Plug in your phone → select it as the run destination → Xcode will prompt for signing. Choose your Apple ID team (Personal Team works for device testing; the paid Developer Program is needed for TestFlight/App Store).

## 5. TestFlight → App Store

1. Enroll at developer.apple.com ($99/yr) if you haven't.
2. In Xcode: Signing & Capabilities → select your team; bundle ID `com.driftlogic.app` (change if taken).
3. Product → Archive → Distribute App → App Store Connect.
4. In App Store Connect: create the app, attach the build, fill in the listing (see `APP-STORE.md`), add screenshots (take them in the simulator: Cmd+S), submit first to TestFlight, then for review.

## 6. Keeping web + app in sync

The engine logic now lives in two places (JS on the site, Swift in the app). When you change one:
- Re-extract the live embed, regenerate `golden.json` (Claude has the script), and run Cmd+U — any divergence fails the tests.
- The old web harness (`Desktop/driftlogic-eval/dl_harness.js`) is stale: its video-bucket list predates the site's current 60-video set. Trust the Swift tests as the canonical check now.

## Known follow-ups

- The live site shows generic "Watch" titles for 40 of its 60 videos (`VID` map never got the new entries). The app has all 69 real titles — consider back-porting `VideoLibrary.swift`'s data to the site embed.
- The web "still current" bug above could also be fixed on the site.
