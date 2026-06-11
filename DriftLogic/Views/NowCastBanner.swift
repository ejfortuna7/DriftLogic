import SwiftUI

/// Live-gauge banner shown above the condition pickers. Mirrors the web
/// tool's "Right now on the Rocky" card: live cfs / °F readout plus a
/// one-tap "Apply to conditions" that fills current, clarity, and temp.
struct NowCastBanner: View {
    @ObservedObject var service: NowCastService
    var onApply: (CurrentSpeed?, WaterClarity?, WaterTemp?) -> Void

    var body: some View {
        switch service.phase {
        case .idle, .failed:
            // Graceful hidden state — no banner, no error chrome.
            EmptyView()
        case .loading:
            loadingRow
        case .loaded:
            loadedCard
        }
    }

    // MARK: Loading

    private var loadingRow: some View {
        HStack(spacing: 10) {
            ProgressView()
                .controlSize(.small)
                .tint(DriftLogicTheme.tealLight)
            Text("Checking the Rocky River gauge…")
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.7))
        }
        .driftLogicCard()
        .transition(.opacity)
    }

    // MARK: Loaded

    private var loadedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("Right now on the Rocky")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(DriftLogicTheme.mist)
                } icon: {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .shadow(color: .green.opacity(0.8), radius: 4)
                }
                Spacer()
                Text("LIVE · USGS Berea")
                    .font(.caption2.weight(.semibold))
                    .tracking(0.5)
                    .foregroundStyle(DriftLogicTheme.tealLight.opacity(0.8))
            }

            Text(readout)
                .font(.title3.weight(.bold))
                .foregroundStyle(DriftLogicTheme.tealLight)

            Text(statusLine)
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                DriftLogicHaptics.tap()
                onApply(service.suggestedCurrent, service.suggestedClarity, service.suggestedTemp)
            } label: {
                Label("Apply to conditions", systemImage: "wand.and.stars")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(DriftLogicTheme.navy)
                    .background {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [DriftLogicTheme.tealLight, DriftLogicTheme.teal],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
            }
            .buttonStyle(.plain)
        }
        .driftLogicCard(accent: DriftLogicTheme.tealLight)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    /// "Rocky River now: 180 cfs · 52°F · Stained"
    private var readout: String {
        var parts: [String] = []
        if let cfs = service.cfs {
            parts.append("\(Int(cfs.rounded())) cfs")
        }
        if let tempF = service.tempF {
            parts.append("\(tempF)°F")
        }
        if let clarity = service.suggestedClarity {
            parts.append(clarity.displayName)
        }
        return "Rocky River now: " + parts.joined(separator: " · ")
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
        } else {
            return "Steelhead have left for the summer — back with the fall rains. Smallmouth are on, though."
        }
    }
}

#Preview("NowCast banner") {
    NowCastBanner(service: NowCastService()) { _, _, _ in }
        .padding()
        .background(DriftLogicTheme.navy)
        .preferredColorScheme(.dark)
}
