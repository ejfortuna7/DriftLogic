import SwiftUI

/// Live-gauge banner for the selected river. Three honest states:
/// - Direct gauge: live readout (cfs · stage · °F · clarity) + apply button.
/// - Indicator gauge (Elk via Brandy Run): clarity read only, clearly labeled —
///   the indicator's cfs is never presented as the river's own flow.
/// - No gauge (Walnut, Ashtabula): says so, and points to manual conditions.
struct NowCastBanner: View {
    @ObservedObject var service: NowCastService

    var body: some View {
        switch service.phase {
        case .idle, .failed:
            // Graceful hidden state — no banner, no error chrome.
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
        VStack(alignment: .leading, spacing: 6) {
            Label {
                Text("No live gauge on \(river.name)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(DriftLogicTheme.mist)
            } icon: {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .imageScale(.small)
                    .foregroundStyle(DriftLogicTheme.salmon)
            }
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

            Text(readout)
                .font(.title3.weight(.bold))
                .foregroundStyle(DriftLogicTheme.tealLight)
                .fixedSize(horizontal: false, vertical: true)

            Text(statusLine)
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Label("Applied to your conditions automatically", systemImage: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(DriftLogicTheme.tealLight.opacity(0.7))
        }
        .driftLogicCard(accent: DriftLogicTheme.tealLight)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    /// Direct: "Rocky now: 228 cfs · 5.9 ft · 81°F · Clear"
    /// Indicator: "Brandy Run indicator: 4 cfs — Elk likely clear"
    private var readout: String {
        if river.isIndicatorGauge {
            var s = "Brandy Run indicator"
            if let cfs = service.cfs { s += ": \(formatted(cfs)) cfs" }
            if let clarity = service.suggestedClarity {
                s += " — \(river.shortName) likely \(clarity.displayName.lowercased())"
            }
            return s
        }

        var parts: [String] = []
        if let cfs = service.cfs { parts.append("\(formatted(cfs)) cfs") }
        if let stage = service.stageFt { parts.append(String(format: "%.1f ft", stage)) }
        if let tempF = service.tempF { parts.append("\(tempF)°F") }
        if let turbidity = service.turbidityFNU { parts.append("\(formatted(turbidity)) FNU") }
        if let clarity = service.suggestedClarity { parts.append(clarity.displayName) }
        return "\(river.shortName) now: " + parts.joined(separator: " · ")
    }

    private func formatted(_ v: Double) -> String {
        v >= 100 ? String(Int(v.rounded())) : String(format: "%.1f", v)
    }

    private var statusLine: String {
        var line: String
        if service.steelheadOn {
            switch service.suggestedTemp {
            case .frigid, .cold:
                line = "Steelhead are on. Cold water — dead-drift eggs and beads, slow and deep."
            case .prime:
                line = "Steelhead are on. Prime water — they'll chase a swung fly or lure."
            default:
                line = "Steelhead are on. They're in the river right now."
            }
        } else {
            line = "Steelhead have left for the summer — back with the fall rains. Smallmouth are on, though."
        }
        if river.isIndicatorGauge {
            line += " (\(river.shortName) has no direct gauge — clarity is read from Brandy Run, the local rain indicator.)"
        }
        return line
    }
}

#Preview("NowCast banner") {
    NowCastBanner(service: NowCastService())
        .padding()
        .background(DriftLogicTheme.navy)
        .preferredColorScheme(.dark)
}
