import Foundation

// MARK: - Core condition types (mirror the web engine's string keys exactly via rawValue)

enum Method: String, CaseIterable, Codable, Identifiable {
    case fly, spin, pin
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .fly: return "Fly"
        case .spin: return "Spinning"
        case .pin: return "Center-Pin"
        }
    }
}

enum Species: String, CaseIterable, Codable, Identifiable {
    case steelhead, smallmouth, walleye, catfish
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .steelhead: return "Steelhead"
        case .smallmouth: return "Smallmouth Bass"
        case .walleye: return "Walleye"
        case .catfish: return "Catfish"
        }
    }
}

enum CurrentSpeed: String, CaseIterable, Codable, Identifiable {
    case still, slow, moderate, fast
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum WaterDepth: String, CaseIterable, Codable, Identifiable {
    case shallow, mid, deep
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .shallow: return "Shallow (<3 ft)"
        case .mid: return "Mid (3–6 ft)"
        case .deep: return "Deep (>6 ft)"
        }
    }
}

enum WaterTemp: String, CaseIterable, Codable, Identifiable {
    case frigid, cold, prime, warm, hot
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .frigid: return "Frigid (<38°F)"
        case .cold: return "Cold (38–45°F)"
        case .prime: return "Prime (45–58°F)"
        case .warm: return "Warm (58–68°F)"
        case .hot: return "Hot (>68°F)"
        }
    }
}

enum WaterClarity: String, CaseIterable, Codable, Identifiable {
    case clear, stained, muddy
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Hatch: String, CaseIterable, Codable, Identifiable {
    case none, egg, bwo, caddis, midge, stonefly
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .none: return "Not sure"
        case .egg: return "Eggs / Spawn"
        case .bwo: return "BWO (Blue-Winged Olive)"
        case .caddis: return "Caddis"
        case .midge: return "Midge"
        case .stonefly: return "Stonefly"
        }
    }
}

// MARK: - Scenario (the full set of selected conditions)

struct Scenario: Codable, Equatable, Hashable {
    var method: Method
    var species: Species
    var current: CurrentSpeed
    var depth: WaterDepth
    var temp: WaterTemp
    var clarity: WaterClarity
    /// Only meaningful when method == .fly. nil == no hatch selected.
    var hatch: Hatch?
}

// MARK: - Engine output types

/// One recommended fly / lure / bait. Mirrors JS {n, x}.
struct Pick: Codable, Equatable {
    let name: String
    let note: String
}

/// One row of the rig table, e.g. ("Fly Line", "Floating WF7F …"). JS setup() row.
struct RigRow: Codable, Equatable {
    let label: String
    let value: String
}

/// "Why This Rig" — headline + exactly 4 rows (Holding Water / Depth & Flow / Temp / Clarity).
struct WhyThisRig: Codable, Equatable {
    let headline: String
    let rows: [RigRow]
}

/// Full result for a scenario.
struct RigResult: Codable, Equatable {
    let rig: [RigRow]          // exactly 3 rows
    let picks: [Pick]          // exactly 5 picks
    let why: WhyThisRig
    let proTip: String
    let videoIDs: [String]     // exactly 5 YouTube video IDs
}

// MARK: - Video metadata

struct VideoInfo: Codable, Equatable, Identifiable {
    let id: String             // YouTube video ID
    let title: String
    let channel: String
    var watchURL: URL { URL(string: "https://www.youtube.com/watch?v=\(id)")! }
    var thumbnailURL: URL { URL(string: "https://i.ytimg.com/vi/\(id)/hqdefault.jpg")! }
}

// MARK: - Engine facade (implemented in RigEngine.swift)

enum DriftLogicEngine {
    /// Compute the full recommendation for a complete scenario.
    /// Must match the verified web engine byte-for-byte (after HTML-entity decoding).
    static func recommend(for s: Scenario) -> RigResult {
        RigResult(
            rig: RigEngine.setup(s),
            picks: RigEngine.picks(s),
            why: RigEngine.why(s),
            proTip: RigEngine.proTip(s),
            videoIDs: VideoLibrary.videoIDs(for: s)
        )
    }
}

// MARK: - Text conventions
// The web engine embeds HTML entities. The Swift port uses real Unicode instead:
//   &ndash;  → "–"   &mdash; → "—"   &middot; → "·"   &amp; → "&"   &deg; → "°"
//   <b>…</b> and other tags are dropped; text is plain.
// Golden-master tests decode entities on the JS side before comparing.
