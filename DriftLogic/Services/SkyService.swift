import Foundation

// MARK: - Light phase (time of day → fishing light level)

/// The fishing-relevant slice of the day. Derived from the clock relative to
/// today's sunrise/sunset, so "low light" tracks the actual horizon rather
/// than a fixed hour. Drives the time-of-day bite-window advisory.
enum LightPhase: String {
    case night, dawn, morning, midday, afternoon, dusk

    enum LightLevel { case low, medium, high }

    var displayName: String {
        switch self {
        case .night: return "Night"
        case .dawn: return "Dawn"
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .afternoon: return "Afternoon"
        case .dusk: return "Dusk"
        }
    }

    var lightLevel: LightLevel {
        switch self {
        case .night, .dawn, .dusk: return .low
        case .morning, .afternoon: return .medium
        case .midday: return .high
        }
    }

    /// Short qualifier for the banner, e.g. "Dawn · low light".
    var lightNote: String {
        switch lightLevel {
        case .low: return "low light"
        case .medium: return "soft light"
        case .high: return "bright sun"
        }
    }

    var systemImage: String {
        switch self {
        case .night: return "moon.stars.fill"
        case .dawn: return "sunrise.fill"
        case .morning: return "sun.haze.fill"
        case .midday: return "sun.max.fill"
        case .afternoon: return "sun.and.horizon.fill"
        case .dusk: return "sunset.fill"
        }
    }

    /// Classify `now` against sunrise/sunset. The ±50-minute windows around
    /// each are the magic low-light hours; the daylight span between is split
    /// into morning / midday / afternoon thirds. Falls back to hour-of-day
    /// buckets when sun times aren't available.
    static func at(
        _ now: Date,
        sunrise: Date?,
        sunset: Date?,
        calendar: Calendar = .current
    ) -> LightPhase {
        let low: TimeInterval = 50 * 60

        if let sunrise, let sunset, sunset > sunrise {
            if now <= sunrise.addingTimeInterval(-low) { return .night }
            if now <= sunrise.addingTimeInterval(low) { return .dawn }
            if now < sunset.addingTimeInterval(-low) {
                let dayStart = sunrise.addingTimeInterval(low)
                let dayEnd = sunset.addingTimeInterval(-low)
                let span = dayEnd.timeIntervalSince(dayStart)
                guard span > 0 else { return .midday }
                let t = now.timeIntervalSince(dayStart) / span
                if t < 1.0 / 3.0 { return .morning }
                if t < 2.0 / 3.0 { return .midday }
                return .afternoon
            }
            if now <= sunset.addingTimeInterval(low) { return .dusk }
            return .night
        }

        // Fallback: simple clock buckets when sun times are missing.
        switch calendar.component(.hour, from: now) {
        case 5 ..< 7: return .dawn
        case 7 ..< 11: return .morning
        case 11 ..< 16: return .midday
        case 16 ..< 19: return .afternoon
        case 19 ..< 21: return .dusk
        default: return .night
        }
    }
}

// MARK: - Time-of-day bite window (species-aware advisory overlay)

/// A short "what's working right now" call, layered on top of the verified
/// rig engine — it never changes the engine's output, it adds the time-of-day
/// context the rig alone can't know (e.g. bass on top at dawn, tubes by midday).
struct BiteWindow: Equatable {
    let title: String
    let detail: String
    let systemImage: String
}

enum BiteWindowAdvisor {
    static func advice(species: Species, phase: LightPhase, steelheadOn: Bool) -> BiteWindow {
        switch species {
        case .smallmouth: return smallmouth(phase)
        case .steelhead: return steelhead(phase)
        case .walleye: return walleye(phase)
        case .catfish: return catfish(phase)
        }
    }

    private static func smallmouth(_ phase: LightPhase) -> BiteWindow {
        switch phase {
        case .dawn, .dusk:
            return BiteWindow(
                title: "Low light — start on top",
                detail: "Walk a spook or pop a popper across flats and current seams. Smallmouth roam shallow and crush surface baits in the soft early/late light — fish it hard before the sun climbs.",
                systemImage: "arrow.up.circle.fill"
            )
        case .night:
            return BiteWindow(
                title: "After dark — big-bass window",
                detail: "Slow, steady, dark profiles. Swim a black jig or wake a buzzbait over shallow rock; the biggest smallmouth prowl skinny water at night.",
                systemImage: "moon.stars.fill"
            )
        case .midday:
            return BiteWindow(
                title: "Sun's overhead — go to the bottom",
                detail: "Bass have pulled tight to rock and the deepest current breaks. Crawl a tube or Ned rig slowly through the holes — exactly what they switch to once the sun is up.",
                systemImage: "arrow.down.circle.fill"
            )
        case .morning, .afternoon:
            return BiteWindow(
                title: "Transition bite",
                detail: "The topwater window is shifting. Keep a reaction bait — spinner or jerkbait — ready up high, but be set to drop to a tube or jig as fish settle deeper.",
                systemImage: "arrow.up.arrow.down.circle.fill"
            )
        }
    }

    private static func steelhead(_ phase: LightPhase) -> BiteWindow {
        switch phase {
        case .dawn, .dusk:
            return BiteWindow(
                title: "Low light — they'll move",
                detail: "Chrome is looser and willing to chase in dim light. Swing a fly or run your float through the heads of runs before the sun is on the water.",
                systemImage: "figure.fishing"
            )
        case .midday:
            return BiteWindow(
                title: "Bright sun — get down and finesse",
                detail: "Fish hold deep and tight in the green slots. Dead-drift eggs or beads clean and slow through the bucket; subtlety beats flash now.",
                systemImage: "arrow.down.circle.fill"
            )
        case .morning, .afternoon:
            return BiteWindow(
                title: "Steady through the day",
                detail: "Work the soft inside seams and tailouts with a clean dead-drift. Cover water and rest each spot between passes.",
                systemImage: "water.waves"
            )
        case .night:
            return BiteWindow(
                title: "Off hours for chrome",
                detail: "Steelhead feed by sight — first and last light are your windows. Rest up and be on the water for the dawn bite.",
                systemImage: "moon.zzz.fill"
            )
        }
    }

    private static func walleye(_ phase: LightPhase) -> BiteWindow {
        switch phase {
        case .dawn, .dusk, .night:
            return BiteWindow(
                title: "Prime walleye light",
                detail: "Dusk into dark is their feeding window. Work jigs and stickbaits along current edges and the lips of drop-offs.",
                systemImage: "moon.stars.fill"
            )
        case .midday:
            return BiteWindow(
                title: "Sun's up — they sulk deep",
                detail: "Slow-jig the bottom of the deepest, shadiest holes and let it sit. Daytime walleye won't move far for it.",
                systemImage: "arrow.down.circle.fill"
            )
        case .morning, .afternoon:
            return BiteWindow(
                title: "Edge bite",
                detail: "Pick apart current seams and structure edges with a jig. The bite sharpens as the light fades toward evening.",
                systemImage: "water.waves"
            )
        }
    }

    private static func catfish(_ phase: LightPhase) -> BiteWindow {
        switch phase {
        case .dusk, .night, .dawn:
            return BiteWindow(
                title: "Cat time",
                detail: "After dark they roam and hunt by scent. Soak cut or punch bait in deep holes and current seams — set your rods and be patient.",
                systemImage: "moon.stars.fill"
            )
        case .morning, .midday, .afternoon:
            return BiteWindow(
                title: "Find the deepest shade",
                detail: "Daytime cats hold in the deepest, shadiest holes. Anchor a smelly bait on the bottom and wait them out.",
                systemImage: "arrow.down.circle.fill"
            )
        }
    }
}

// MARK: - Sky service (air temperature + sunrise/sunset via Open-Meteo)

/// Fetches current air temperature and today's sunrise/sunset for the selected
/// river's coordinates from Open-Meteo. One anonymous request keyed on the
/// RIVER's location (never the device's) — no API key, no personal data.
@MainActor
final class SkyService: ObservableObject {

    enum Phase: Equatable { case idle, loading, loaded, failed }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var airTempF: Int?
    @Published private(set) var sunrise: Date?
    @Published private(set) var sunset: Date?
    @Published private(set) var fetchedAt: Date?

    private var loadTask: Task<Void, Never>?

    func reload(for river: River) {
        loadTask?.cancel()
        loadTask = Task { await load(for: river) }
    }

    func load(for river: River) async {
        phase = .loading
        airTempF = nil
        sunrise = nil
        sunset = nil

        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        comps.queryItems = [
            URLQueryItem(name: "latitude", value: String(river.latitude)),
            URLQueryItem(name: "longitude", value: String(river.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "daily", value: "sunrise,sunset"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "forecast_days", value: "1"),
        ]
        guard let url = comps.url else { phase = .failed; return }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
                phase = .failed
                return
            }
            apply(try JSONDecoder().decode(OpenMeteoResponse.self, from: data))
        } catch {
            phase = .failed
        }
    }

    private func apply(_ r: OpenMeteoResponse) {
        if let t = r.current?.temperature_2m { airTempF = Int(t.rounded()) }
        let tz = r.timezone.flatMap(TimeZone.init(identifier:)) ?? .current
        sunrise = r.daily?.sunrise.first.flatMap { OpenMeteoResponse.parseLocal($0, tz: tz) }
        sunset = r.daily?.sunset.first.flatMap { OpenMeteoResponse.parseLocal($0, tz: tz) }
        fetchedAt = Date()
        phase = (airTempF != nil || sunrise != nil) ? .loaded : .failed
    }

    /// The current light phase, computed from today's sun times.
    var lightPhase: LightPhase {
        LightPhase.at(Date(), sunrise: sunrise, sunset: sunset)
    }
}

// MARK: - Open-Meteo JSON

private struct OpenMeteoResponse: Decodable {
    struct Current: Decodable { let temperature_2m: Double? }
    struct Daily: Decodable { let sunrise: [String]; let sunset: [String] }

    let current: Current?
    let daily: Daily?
    let timezone: String?

    /// Open-Meteo returns local wall-clock strings ("2026-06-16T05:54") when a
    /// timezone is requested; parse them in that zone to get an absolute Date.
    static func parseLocal(_ s: String, tz: TimeZone) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = tz
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f.date(from: s)
    }
}
