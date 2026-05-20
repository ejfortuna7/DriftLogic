import SwiftUI

struct WhyThisRigView: View {
    let rationale: RigRationale

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(rationale.headline)
                .font(.subheadline)
                .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.92))

            ForEach(rationale.bullets) { bullet in
                HStack(alignment: .top, spacing: 10) {
                    Text(bullet.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DriftLogicTheme.salmonPink.opacity(0.95))
                        .frame(width: 76, alignment: .leading)
                    Text(bullet.detail)
                        .font(.subheadline)
                        .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .driftLogicListRow()
        .textCase(nil)
    }
}

#Preview {
    Form {
        WhyThisRigView(
            rationale: RigRationaleBuilder.build(
                waterType: .smallStream,
                current: .slow,
                depth: .shallow,
                temp: .prime,
                turbidity: .clear,
                species: .trout,
                hatch: .blueWingedOlive
            ),
        )
    }
}
