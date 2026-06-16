import SwiftUI

/// Live-conditions banner for the selected river. Reads two sources:
/// - `service` (USGS): flow, stage, water temp, turbidity/clarity.
/// - `sky` (Open-Meteo): air temperature + sunrise/sunset → time-of-day light.
///
/// Three honest states:
/// - Direct gauge: labeled metric grid (Flow · Stage · Water · Air · Clarity)
///   plus a Time/Light row, with an "as of" freshness stamp.
/// - Indicator gauge (Elk via Brandy Run): clarity inference only, clearly
///   labeled — the indicator's cfs is never presented as the river's own flow.
/// - No gauge (Walnut, Ashtabula): air + time still shown (weather needs no
///   USGS station), with a prompt to set conditions manually.
struct NowCastBanner: View {
    @ObservedObject var service: NowCastService
    @ObservedObject var sky: SkyService

    var body: some View {
        switch service.phase {
        case .idle, .failed:
            EmptyView()
        case .loading:
            loadingRow
        case .loaded:
            loadedCard
        case .unavailable:
            unavailableCard
        }
    }

    private var river: River { service.river }

    // MARK: Loading

    private var loadingRow: some View {
        HStack(spacing: 10) {
            ProgressView()
                .controlSize(.small)
                .tint(DriftLogicTheme.tealLight)
            Text("Checking the \(river.shortName) gauge…")
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.7))
        }
        .driftLogicCard()
        .transition(.opacity)
    }

    // MARK: No gauge

    private var unavailableCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("No live gauge on \(river.name)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(DriftLogicTheme.mist)
            } icon: {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .imageScale(.small)
                    .foregroundStyle(DriftLogicTheme.salmon)
            }

            // Weather works anywhere — show air + time even with no USGS station.
            if !skyTiles.isEmpty {
                metricGrid(skyTiles)
            }
            lightRow

            Text("USGS doesn't monitor this creek. Eyeball the water and set conditions below — DriftLogic does the rest.")
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .driftLogicCard(accent: DriftLogicTheme.salmon)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: Loaded

    private var loadedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("Right now on the \(river.shortName)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(DriftLogicTheme.mist)
                } icon: {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .shadow(color: .green.opacity(0.8), radius: 4)
                }
                Spacer()
                Text("LIVE · \(river.gaugeName ?? "USGS")")
                    .font(.caption2.weight(.semibold))
                    .tracking(0.5)
                    .foregroundStyle(DriftLogicTheme.tealLight.opacity(0.8))
            }

            metricGrid(loadedTiles)

            lightRow

            if river.isIndicatorGauge {
                Text(indicatorNote)
                    .font(.caption)
                    .foregroundStyle(DriftLogicTheme.mist.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(statusLine)
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                Text(freshnessLine)
            }
            .font(.caption2)
            .foregroundStyle(DriftLogicTheme.tealLight.opacity(0.7))
        }
        .driftLogicCard(accent: DriftLogicTheme.tealLight)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: Metric tiles

    private struct Metric: Identifiable {
        let id = UUID()
        let label: String
        let value: String
        let systemImage: String
    }

    /// Water metrics for a directly gauged river. Indicator rivers skip Flow
    /// (their cfs isn't this river's own) and lean on the clarity inference.
    private var loadedTiles: [Metric] {
        var tiles: [Metric] = []
        if !river.isIndicatorGauge, let cfs = service.cfs {
            tiles.append(Metric(label: "FLOW", value: "\(formatted(cfs)) cfs", systemImage: "water.waves"))
        }
        if let stage = service.stageFt {
            tiles.append(Metric(label: "STAGE", value: String(format: "%.1f ft", stage), systemImage: "ruler"))
        }
        if let tempF = service.tempF {
            tiles.append(Metric(label: "WATER", value: "\(tempF)°F", systemImage: "thermometer.medium"))
        }
        tiles.append(contentsOf: skyTiles)
        if let clarity = service.suggestedClarity {
            tiles.append(Metric(label: "CLARITY", value: clarity.displayName, systemImage: "eye"))
        }
        return tiles
    }

    /// Air temperature — shown on every river (gauged or not).
    private var skyTiles: [Metric] {
        guard let air = sky.airTempF else { return [] }
        return [Metric(label: "AIR", value: "\(air)°F", systemImage: "cloud.sun")]
    }

    private func metricGrid(_ metrics: [Metric]) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach(metrics) { m in
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: m.systemImage)
                            .font(.caption2)
                            .foregroundStyle(DriftLogicTheme.tealLight)
                        Text(m.label)
                            .font(.caption2.weight(.bold))
                            .tracking(0.5)
                            .foregroundStyle(DriftLogicTheme.mist.opacity(0.55))
                    }
                    Text(m.value)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(DriftLogicTheme.mist)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                }
            }
        }
    }

    // MARK: Time / light row

    private var lightRow: some View {
        let phase = sky.lightPhase
        return HStack(spacing: 8) {
            Image(systemName: phase.systemImage)
                .font(.subheadline)
                .foregroundStyle(DriftLogicTheme.gold)
            Text("\(clockNow) · \(phase.displayName)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DriftLogicTheme.mist)
            Text("— \(phase.lightNote)")
                .font(.caption)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.6))
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DriftLogicTheme.gold.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(DriftLogicTheme.gold.opacity(0.25), lineWidth: 1)
                }
        }
    }

    // MARK: Strings

    private var indicatorNote: String {
        var s = "Brandy Run indicator"
        if let cfs = service.cfs { s += ": \(formatted(cfs)) cfs" }
        if let clarity = service.suggestedClarity {
            s += " — \(river.shortName) likely \(clarity.displayName.lowercased())"
        }
        s += ". (\(river.shortName) has no direct gauge — clarity is read from Brandy Run, the local rain indicator.)"
        return s
    }

    private func formatted(_ v: Double) -> String {
        v >= 100 ? String(Int(v.rounded())) : String(format: "%.1f", v)
    }

    private var clockNow: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "h:mm a"
        return f.string(from: Date())
    }

    private var freshnessLine: String {
        if let observed = service.observedAt {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "h:mm a"
            let stamp = f.string(from: observed)
            return "Gauge as of \(stamp) · air & light live · applied automatically"
        }
        return "Applied to your conditions automatically"
    }

    private var statusLine: String {
        if service.steelheadOn {
            switch service.suggestedTemp {
            case .frigid, .cold:
                return "Steelhead are on. Cold water — dead-drift eggs and beads, slow and deep."
            case .prime:
                return "Steelhead are on. Prime water — they'll chase a swung fly or lure."
            default:
                return "Steelhead are on. They're in the river right now."
            }
        }
        return "Steelhead have left for the summer — back with the fall rains. Smallmouth are on, though."
    }
}

#Preview("NowCast banner") {
    NowCastBanner(service: NowCastService(), sky: SkyService())
        .padding()
        .background(DriftLogicTheme.navy)
        .preferredColorScheme(.dark)
}
