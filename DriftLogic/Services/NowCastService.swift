import Foundation

/// Live conditions for the selected Steelhead Alley river.
///
/// Accuracy rules (per the June 2026 gauge audit):
/// - Fetches discharge (00060), water temp (00010), gage height (00065),
///   and turbidity (63680) for the river's USGS station.
/// - Any reading older than `freshnessWindow` is DISCARDED — several Alley
///   stations have seasonal or dead sensors that still return stale values
///   (e.g. Vermilion's temp sensor last reported the previous November).
/// - Clarity prefers a fresh turbidity sensor (Cattaraugus has one) and
///   falls back to per-river cfs thresholds.
/// - Indicator gauges (Elk Creek via Brandy Run) infer clarity only; their
///   cfs is never presented as the river's own flow and never drives the
///   current-speed suggestion.
/// - Ungauged rivers (Walnut, Ashtabula) report `.unavailable` so the UI
///   can route the user to manual conditions.
@MainActor
final class NowCastService: ObservableObject {

    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed
        case unavailable   // river has no gauge — manual conditions
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var river: River = SteelheadAlley.defaultRiver

    /// Raw readings (already freshness-filtered). For indicator gauges,
    /// `cfs` is the indicator stream's flow — see `river.isIndicatorGauge`.
    @Published private(set) var cfs: Double?
    @Published private(set) var tempF: Int?
    @Published private(set) var stageFt: Double?
    @Published private(set) var turbidityFNU: Double?

    /// Suggested condition bands (nil when the underlying reading is missing).
    @Published private(set) var suggestedCurrent: CurrentSpeed?
    @Published private(set) var suggestedClarity: WaterClarity?
    @Published private(set) var suggestedTemp: WaterTemp?

    /// Steelhead-season call: water ≤ 57°F, or (no temp) October–April.
    @Published private(set) var steelheadOn: Bool = false

    /// Readings older than this are treated as missing.
    private let freshnessWindow: TimeInterval = 6 * 60 * 60

    private var loadTask: Task<Void, Never>?

    func load(river: River? = nil) async {
        let target = river ?? self.river
        self.river = target

        guard let siteID = target.siteID else {
            resetReadings()
            phase = .unavailable
            applySeasonalSteelheadCall()
            return
        }

        phase = .loading
        resetReadings()

        guard let url = URL(string:
            "https://waterservices.usgs.gov/nwis/iv/?format=json&sites=\(siteID)&parameterCd=00060,00010,00065,63680&siteStatus=all"
        ) else { phase = .failed; return }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
                phase = .failed
                return
            }
            apply(try JSONDecoder().decode(USGSResponse.self, from: data), for: target)
        } catch {
            phase = .failed
        }
    }

    func reload(for river: River) {
        loadTask?.cancel()
        loadTask = Task { await load(river: river) }
    }

    private func resetReadings() {
        cfs = nil; tempF = nil; stageFt = nil; turbidityFNU = nil
        suggestedCurrent = nil; suggestedClarity = nil; suggestedTemp = nil
    }

    private func apply(_ payload: USGSResponse, for river: River) {
        let cutoff = Date().addingTimeInterval(-freshnessWindow)

        let cfs = payload.freshestValue(forParameter: "00060", notBefore: cutoff)
        let tempC = payload.freshestValue(forParameter: "00010", notBefore: cutoff)
        let stage = payload.freshestValue(forParameter: "00065", notBefore: cutoff)
        let turbidity = payload.freshestValue(forParameter: "63680", notBefore: cutoff)
        let tempF: Int? = tempC.map { Int(($0 * 9 / 5 + 32).rounded()) }

        guard cfs != nil || tempF != nil || turbidity != nil || stage != nil else {
            phase = .failed
            return
        }

        self.cfs = cfs
        self.tempF = tempF
        self.stageFt = stage
        self.turbidityFNU = turbidity

        // Clarity: fresh turbidity sensor first, then per-river cfs bands.
        if let turbidity {
            suggestedClarity = turbidity < 10 ? .clear : (turbidity < 45 ? .stained : .muddy)
        } else if let cfs, let clear = river.clearBelowCfs, let stained = river.stainedBelowCfs {
            suggestedClarity = cfs < clear ? .clear : (cfs < stained ? .stained : .muddy)
        }

        // Current speed: only meaningful when the gauge measures THIS river.
        if !river.isIndicatorGauge, let cfs, let lo = river.primeFlowLow, let hi = river.primeFlowHigh {
            suggestedCurrent = cfs < lo ? .slow : (cfs <= hi * 1.6 ? .moderate : .fast)
        }

        if let tempF {
            suggestedTemp = tempF < 42 ? .frigid
                : tempF < 50 ? .cold
                : tempF < 64 ? .prime
                : tempF < 75 ? .warm
                : .hot
            steelheadOn = tempF <= 57
        } else {
            applySeasonalSteelheadCall()
        }

        phase = .loaded
    }

    private func applySeasonalSteelheadCall() {
        let month = Calendar.current.component(.month, from: Date())
        steelheadOn = month >= 10 || month <= 4
    }
}

// MARK: - USGS Instantaneous Values JSON

private struct USGSResponse: Decodable {
    struct Value: Decodable {
        let timeSeries: [TimeSeries]
    }

    struct TimeSeries: Decodable {
        let variable: Variable
        let values: [ValueBlock]
    }

    struct Variable: Decodable {
        let variableCode: [VariableCode]
    }

    struct VariableCode: Decodable {
        let value: String
    }

    struct ValueBlock: Decodable {
        let value: [DataPoint]
    }

    struct DataPoint: Decodable {
        let value: String
        let dateTime: String
    }

    let value: Value

    private static let isoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let iso: ISO8601DateFormatter = ISO8601DateFormatter()

    private static func parseDate(_ s: String) -> Date? {
        isoFractional.date(from: s) ?? iso.date(from: s)
    }

    /// Newest reading for a parameter across ALL value blocks (stations can
    /// expose several methods/sensors per parameter), discarding the USGS
    /// missing-data sentinel and anything older than `notBefore`. This is
    /// the freshness guard that keeps dead/seasonal sensors out of the UI.
    func freshestValue(forParameter code: String, notBefore cutoff: Date) -> Double? {
        var best: (date: Date, value: Double)?
        for series in value.timeSeries where series.variable.variableCode.first?.value == code {
            for block in series.values {
                for point in block.value {
                    guard
                        let number = Double(point.value), number > -999_990,
                        let date = Self.parseDate(point.dateTime),
                        date >= cutoff
                    else { continue }
                    if best == nil || date > best!.date {
                        best = (date, number)
                    }
                }
            }
        }
        return best?.value
    }
}
