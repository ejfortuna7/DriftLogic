import SwiftUI

/// Renders a complete `RigResult`: headline, rig table, Top 5 Picks
/// (with shop links), Why This Rig, and the Pro Tip.
struct ResultsView: View {
    let result: RigResult
    let method: Method

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Lead headline
            Text(result.why.headline)
                .font(.headline)
                .foregroundStyle(DriftLogicTheme.mist)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)

            rigCard
            picksCard
            whyCard
            proTipCard
        }
    }

    // MARK: Rig table

    private var rigTitle: String {
        switch method {
        case .fly: return "Your Fly Rig"
        case .spin: return "Your Spinning Setup"
        case .pin: return "Your Center-Pin Setup"
        }
    }

    private var rigCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(rigTitle, systemImage: "list.bullet.rectangle", tint: DriftLogicTheme.tealLight)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(result.rig.enumerated()), id: \.offset) { index, row in
                    if index > 0 {
                        Divider()
                            .overlay(DriftLogicTheme.teal.opacity(0.2))
                            .padding(.vertical, 10)
                    }
                    labeledRow(label: row.label, value: row.value, labelTint: DriftLogicTheme.tealLight)
                }
            }
        }
        .driftLogicCard()
    }

    // MARK: Top 5 Picks

    private var picksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader("Top 5 Picks", systemImage: "star.fill", tint: DriftLogicTheme.gold)

            VStack(spacing: 10) {
                ForEach(Array(result.picks.enumerated()), id: \.offset) { index, pick in
                    pickRow(pick, rank: index + 1)
                }
            }

            Text("As an Amazon Associate, we earn from qualifying purchases.")
                .font(.caption2)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.45))
        }
        .driftLogicCard(accent: DriftLogicTheme.gold)
    }

    private func pickRow(_ pick: Pick, rank: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(rank)")
                .font(.footnote.weight(.bold))
                .foregroundStyle(DriftLogicTheme.navy)
                .frame(width: 24, height: 24)
                .background(Circle().fill(DriftLogicTheme.gold))

            VStack(alignment: .leading, spacing: 5) {
                Text(pick.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DriftLogicTheme.mist)
                    .fixedSize(horizontal: false, vertical: true)

                Text(pick.note)
                    .font(.footnote)
                    .foregroundStyle(DriftLogicTheme.mist.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    shopButton("Amazon", url: ShopLinks.amazonURL(for: pick.name), tint: DriftLogicTheme.orange)
                    shopButton("FishUSA", url: ShopLinks.fishUSAURL(for: pick.name), tint: DriftLogicTheme.tealLight)
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.04))
        }
    }

    private func shopButton(_ title: String, url: URL, tint: Color) -> some View {
        Link(destination: url) {
            HStack(spacing: 4) {
                Text(title)
                Image(systemName: "arrow.up.right")
                    .imageScale(.small)
            }
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(tint)
            .background {
                Capsule(style: .continuous)
                    .strokeBorder(tint.opacity(0.5), lineWidth: 1)
            }
        }
    }

    // MARK: Why This Rig

    private var whyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader("Why This Rig", systemImage: "questionmark.bubble", tint: DriftLogicTheme.teal)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(result.why.rows.enumerated()), id: \.offset) { index, row in
                    if index > 0 {
                        Divider()
                            .overlay(DriftLogicTheme.teal.opacity(0.2))
                            .padding(.vertical, 10)
                    }
                    labeledRow(label: row.label, value: row.value, labelTint: DriftLogicTheme.teal)
                }
            }
        }
        .driftLogicCard()
    }

    // MARK: Pro Tip

    private var proTipCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            cardHeader("Pro Tip", systemImage: "bolt.fill", tint: DriftLogicTheme.gold)

            Text(result.proTip)
                .font(.subheadline)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .driftLogicCard(accent: DriftLogicTheme.gold)
    }

    // MARK: Shared pieces

    private func cardHeader(_ title: String, systemImage: String, tint: Color) -> some View {
        Label {
            Text(title)
                .font(.subheadline.weight(.bold))
                .tracking(0.4)
                .textCase(.uppercase)
        } icon: {
            Image(systemName: systemImage)
                .imageScale(.small)
        }
        .foregroundStyle(tint)
    }

    private func labeledRow(label: String, value: String, labelTint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption.weight(.bold))
                .tracking(0.4)
                .textCase(.uppercase)
                .foregroundStyle(labelTint.opacity(0.9))
            Text(value)
                .font(.subheadline)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Results") {
    ScrollView {
        ResultsView(
            result: RigResult(
                rig: [
                    RigRow(label: "Rod & line", value: "9 ft 7-wt weight-forward floating"),
                    RigRow(label: "Leader", value: "9–10 ft tapered for indicator nymphing"),
                    RigRow(label: "Tippet", value: "2X–3X fluorocarbon"),
                ],
                picks: [
                    Pick(name: "Glo Bug Egg #10–12", note: "Dead-drift the tailouts; the winter staple"),
                    Pick(name: "Stonefly Nymph #8–10", note: "Add shot to reach the deeper slots"),
                    Pick(name: "Sucker Spawn", note: "Natural orange or pale, drag-free"),
                    Pick(name: "Crystal Meth Egg #10–12", note: "Bright egg for cold, clear flows"),
                    Pick(name: "Hares Ear Nymph #12–14", note: "Natural dropper below the egg"),
                ],
                why: WhyThisRig(
                    headline: "Built for Steelhead on the Rocky River — fly fishing, mid / moderate water at 42–50°F, clear clarity.",
                    rows: [
                        RigRow(label: "Where", value: "Steelhead hold in tailouts and riffle heads."),
                        RigRow(label: "Flow", value: "Moderate flow is ideal."),
                        RigRow(label: "Temp", value: "Prime steelhead water."),
                        RigRow(label: "Clarity", value: "Clear water — downsize and go natural."),
                    ]
                ),
                proTip: "Dead-drift eggs and nymphs through the tailouts and keep your drift drag-free.",
                videoIDs: []
            ),
            method: .fly
        )
        .padding()
    }
    .background(DriftLogicTheme.navy)
    .preferredColorScheme(.dark)
}
