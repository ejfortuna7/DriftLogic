import Foundation

/// Live conditions from the USGS Rocky River gauge near Berea, OH
/// (site 04201500). Swift port of the web tool's `dlNowInit` / `renderNow`:
/// fetches instantaneous discharge (00060, cfs) and water temperature
/// (00010, °C) and maps them onto DriftLogic condition bands using the
/// exact thresholds the web tool uses.
@MainActor
final class NowCastService: ObservableObject {

    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed
    }

    @Published private(set) var phase: Phase = .idle

    /// Raw discharge in cubic feet per second, if the gauge reported it.
    @Published private(set) var cfs: Double?
    /// Water temperature in °F (rounded, converted from the gauge's °C).
    @Published private(set) var tempF: Int?

    /// Suggested condition bands (nil when the underlying reading is missing).
    @Published private(set) var suggestedCurrent: CurrentSpeed?
    @Published private(set) var suggestedClarity: WaterClarity?
    @Published private(set) var suggestedTemp: WaterTemp?

    /// Mirrors the web tool's steelhead-season call: water ≤ 57°F, or
    /// (no temp reading) October through April.
    @Published private(set) var steelheadOn: Bool = false

    private static let gaugeURL = URL(
        string: "https://waterservices.usgs.gov/nwis/iv/?format=json&sites=04201500&parameterCd=00060,00010&siteStatus=all"
    )!

    func load() async {
        guard phase != .loading else { return }
        phase = .loading

        do {
            var request = URLRequest(url: Self.gaugeURL)
            request.timeoutInterval = 15
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
                phase = .failed
                return
            }
            apply(try JSONDecoder().decode(USGSResponse.self, from: data))
        } catch {
            phase = .failed
        }
    }

    private func apply(_ payload: USGSResponse) {
        let cfs = payload.latestValue(forParameter: "00060")
        let tempC = payload.latestValue(forParameter: "00010")
        let tempF: Int? = tempC.map { Int(($0 * 9 / 5 + 32).rounded()) }

        guard cfs != nil || tempF != nil else {
            phase = .failed
            return
        }

        self.cfs = cfs
        self.tempF = tempF

        // Thresholds match the web tool's dlNowInit exactly.
        if let cfs {
            suggestedClarity = cfs < 250 ? .clear : (cfs < 500 ? .stained : .muddy)
            suggestedCurrent = cfs < 150 ? .slow : (cfs <= 400 ? .moderate : .fast)
        } else {
            suggestedClarity = nil
            suggestedCurrent = nil
        }

        if let tempF {
            suggestedTemp = tempF < 42 ? .frigid
                : tempF < 50 ? .cold
                : tempF < 64 ? .prime
                : tempF < 75 ? .warm
                : .hot
        } else {
            suggestedTemp = nil
        }

        if let tempF {
            steelheadOn = tempF <= 57
        } else {
            let month = Calendar.current.component(.month, from: Date())
            steelheadOn = month >= 10 || month <= 4
        }

        phase = .loaded
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
    }

    let value: Value

    /// Last reported reading for a USGS parameter code, ignoring the
    /// gauge's missing-data sentinel (-999999).
    func latestValue(forParameter code: String) -> Double? {
        guard
            let series = value.timeSeries.first(where: {
                $0.variable.variableCode.first?.value == code
            }),
            let raw = series.values.first?.value.last?.value,
            let number = Double(raw),
            number > -999_990
        else { return nil }
        return number
    }
}
