import Foundation

/// A Steelhead Alley tributary. Gauge wiring and condition thresholds are
/// per-river, based on a June 2026 audit of what each USGS station actually
/// reports live (several stations have dead or seasonal sensors — the
/// NowCast layer additionally enforces a freshness window so stale readings
/// are never shown).
struct River: Identifiable, Hashable {
    enum GaugeKind: Hashable {
        /// Station measures this river directly.
        case direct(siteID: String)
        /// Station is a nearby proxy anglers use to judge this river
        /// (e.g. Brandy Run for Elk Creek). Clarity inference only —
        /// the cfs number is NOT this river's flow.
        case indicator(siteID: String, label: String)
        /// No active USGS station — conditions are set manually.
        case none
    }

    let id: String
    let name: String            // "Rocky River"
    let shortName: String       // "Rocky" — used in sentence substitution ("the Rocky")
    let state: String           // "OH" / "PA" / "NY"
    let gauge: GaugeKind
    let gaugeName: String?      // "USGS Berea" — shown in the LIVE badge

    /// Prime fishing flow band in cfs (display + current-speed inference).
    /// nil for indicator/ungauged rivers.
    let primeFlowLow: Double?
    let primeFlowHigh: Double?

    /// cfs below which the river typically runs clear / merely stained.
    /// For indicator gauges these are on the INDICATOR's scale.
    let clearBelowCfs: Double?
    let stainedBelowCfs: Double?

    /// Representative coordinates (gauge or town) for the river. Used for the
    /// air-temperature + sunrise/sunset lookup — works even on ungauged rivers,
    /// since weather doesn't depend on a USGS station. All Alley tribs are in
    /// the America/New_York time zone.
    let latitude: Double
    let longitude: Double

    var siteID: String? {
        switch gauge {
        case .direct(let id), .indicator(let id, _): return id
        case .none: return nil
        }
    }

    var isIndicatorGauge: Bool {
        if case .indicator = gauge { return true }
        return false
    }

    var primeFlowText: String? {
        guard let lo = primeFlowLow, let hi = primeFlowHigh else { return nil }
        return "\(Int(lo))–\(Int(hi)) cfs"
    }
}

enum SteelheadAlley {
    /// West → east along the lake. Audited 2026-06-11 against
    /// waterservices.usgs.gov (live parameters noted per station).
    static let rivers: [River] = [
        River(
            id: "vermilion", name: "Vermilion River", shortName: "Vermilion", state: "OH",
            gauge: .direct(siteID: "04199500"), gaugeName: "USGS Vermilion",
            // Live: cfs, stage. Temp + turbidity sensors are seasonal (stale in summer).
            primeFlowLow: 100, primeFlowHigh: 300, clearBelowCfs: 250, stainedBelowCfs: 500,
            latitude: 41.392, longitude: -82.363
        ),
        River(
            id: "rocky", name: "Rocky River", shortName: "Rocky", state: "OH",
            gauge: .direct(siteID: "04201500"), gaugeName: "USGS Berea",
            // Live: cfs, temp, stage. The original DriftLogic river.
            primeFlowLow: 150, primeFlowHigh: 250, clearBelowCfs: 250, stainedBelowCfs: 500,
            latitude: 41.406, longitude: -81.889
        ),
        River(
            id: "cuyahoga", name: "Cuyahoga River (lower)", shortName: "Cuyahoga", state: "OH",
            gauge: .direct(siteID: "04208000"), gaugeName: "USGS Independence",
            // Live: cfs, temp, stage. Big water — bands scaled accordingly.
            primeFlowLow: 800, primeFlowHigh: 1500, clearBelowCfs: 900, stainedBelowCfs: 1800,
            latitude: 41.393, longitude: -81.631
        ),
        River(
            id: "chagrin", name: "Chagrin River", shortName: "Chagrin", state: "OH",
            gauge: .direct(siteID: "04209000"), gaugeName: "USGS Willoughby",
            // Live: cfs, stage. No temperature sensor at this station.
            primeFlowLow: 150, primeFlowHigh: 350, clearBelowCfs: 300, stainedBelowCfs: 600,
            latitude: 41.640, longitude: -81.406
        ),
        River(
            id: "grand", name: "Grand River", shortName: "Grand", state: "OH",
            gauge: .direct(siteID: "04212100"), gaugeName: "USGS Painesville",
            // Live: cfs, temp, stage. Slow to clear after rain.
            primeFlowLow: 300, primeFlowHigh: 700, clearBelowCfs: 450, stainedBelowCfs: 900,
            latitude: 41.726, longitude: -81.235
        ),
        River(
            id: "ashtabula", name: "Ashtabula River", shortName: "Ashtabula", state: "OH",
            gauge: .none, gaugeName: nil,
            // No active USGS station — manual conditions.
            primeFlowLow: nil, primeFlowHigh: nil, clearBelowCfs: nil, stainedBelowCfs: nil,
            latitude: 41.865, longitude: -80.790
        ),
        River(
            id: "conneaut", name: "Conneaut Creek", shortName: "Conneaut", state: "OH",
            gauge: .direct(siteID: "04213000"), gaugeName: "USGS Conneaut",
            // Live: cfs, stage. No temperature sensor.
            primeFlowLow: 100, primeFlowHigh: 300, clearBelowCfs: 250, stainedBelowCfs: 500,
            latitude: 41.940, longitude: -80.554
        ),
        River(
            id: "elk", name: "Elk Creek", shortName: "Elk", state: "PA",
            gauge: .indicator(siteID: "04213075", label: "Brandy Run indicator"),
            gaugeName: "USGS Brandy Run (indicator)",
            // Elk has no direct gauge; Brandy Run is the local rain/mud
            // indicator. Thresholds are on Brandy Run's small-stream scale,
            // clarity inference only — never shown as Elk's own flow.
            primeFlowLow: nil, primeFlowHigh: nil, clearBelowCfs: 8, stainedBelowCfs: 25,
            latitude: 42.020, longitude: -80.366
        ),
        River(
            id: "walnut", name: "Walnut Creek", shortName: "Walnut", state: "PA",
            gauge: .none, gaugeName: nil,
            primeFlowLow: nil, primeFlowHigh: nil, clearBelowCfs: nil, stainedBelowCfs: nil,
            latitude: 42.030, longitude: -80.255
        ),
        River(
            id: "cattaraugus", name: "Cattaraugus Creek", shortName: "Cattaraugus", state: "NY",
            gauge: .direct(siteID: "04213500"), gaugeName: "USGS Gowanda",
            // Live: cfs, temp, stage, AND turbidity — clarity uses the real
            // turbidity sensor here. Big glacial-clay drainage.
            primeFlowLow: 300, primeFlowHigh: 700, clearBelowCfs: 500, stainedBelowCfs: 1200,
            latitude: 42.464, longitude: -78.936
        ),
    ]

    static let defaultRiver = rivers.first { $0.id == "rocky" }!

    static func river(withID id: String) -> River? {
        rivers.first { $0.id == id }
    }

    static var groupedByState: [(state: String, rivers: [River])] {
        [("Ohio", rivers.filter { $0.state == "OH" }),
         ("Pennsylvania", rivers.filter { $0.state == "PA" }),
         ("New York", rivers.filter { $0.state == "NY" })]
    }
}

// MARK: - Display-level river text substitution
//
// The engine's strings were written for the Rocky River (and are locked by
// the golden-master tests). For other rivers we adapt the text at render
// time: river names, the prime-flow band, and Rocky-specific landmarks.

enum RiverText {
    static func localize(_ text: String, for river: River) -> String {
        guard river.id != "rocky" else { return text }
        var t = text

        // Rocky-only landmark references → generic equivalents.
        t = t.replacingOccurrences(of: "the mouth and Emerald Necklace Marina", with: "the river mouth")
        t = t.replacingOccurrences(of: "near the mouth and the marina", with: "near the river mouth")

        // Prime-flow band: "150 and 250 cfs" / "150–250 cfs" → this river's band
        // (or drop the claim entirely when we don't have a vetted band).
        if let band = river.primeFlowText {
            t = t.replacingOccurrences(of: "150–250 cfs", with: band)
            t = t.replacingOccurrences(
                of: "between 150 and 250 cfs",
                with: "between \(bandWords(river))")
        } else {
            t = t.replacingOccurrences(of: " The Rocky fishes best around 150–250 cfs.", with: "")
            t = t.replacingOccurrences(of: "; the river fishes best between 150 and 250 cfs", with: "")
        }

        // River names, most-specific first (both sentence positions).
        t = t.replacingOccurrences(of: "Rocky River", with: river.name)
        t = t.replacingOccurrences(of: "the Rocky", with: "the \(river.shortName)")
        t = t.replacingOccurrences(of: "The Rocky", with: "The \(river.shortName)")
        return t
    }

    private static func bandWords(_ river: River) -> String {
        guard let lo = river.primeFlowLow, let hi = river.primeFlowHigh else { return "" }
        return "\(Int(lo)) and \(Int(hi)) cfs"
    }
}
