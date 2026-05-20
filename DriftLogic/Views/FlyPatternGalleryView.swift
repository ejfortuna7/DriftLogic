import SwiftUI

struct FlyPatternGalleryView: View {
    let flies: [RecommendedFly]
    let refreshKey: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if flies.isEmpty {
                Text("No fly patterns matched these conditions.")
                    .font(.caption)
                    .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.7))
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(flies.enumerated()), id: \.element.id) { index, fly in
                        FlyPatternPhotoCard(fly: fly, rank: index + 1, refreshKey: refreshKey)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .id(refreshKey)
    }
}

private struct FlyPatternPhotoCard: View {
    let fly: RecommendedFly
    let rank: Int
    let refreshKey: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            flyImage
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .id("\(refreshKey)-\(fly.id)")

            flyTitleRow

            if !fly.tactic.isEmpty {
                Text(fly.tactic)
                    .font(.caption)
                    .foregroundStyle(DriftLogicTheme.riverTeal.opacity(0.95))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Link("View on Wikimedia Commons", destination: fly.photo.sourcePageURL)
                .font(.caption)
                .tint(DriftLogicTheme.riverTeal)

            Text("\(fly.photo.license) · \(fly.photo.credit)")
                .font(.caption2)
                .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.65))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DriftLogicTheme.steelheadNavy.opacity(0.78))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(DriftLogicTheme.riverTeal.opacity(0.45), lineWidth: 1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var flyTitleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(rank).")
                .font(.caption.weight(.bold))
                .foregroundStyle(DriftLogicTheme.salmonPink)
                .frame(width: 22, alignment: .leading)

            Text(fly.displayLine)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DriftLogicTheme.riverMist)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var flyImage: some View {
        AsyncImage(url: fly.photo.imageURL) { phase in
            switch phase {
            case .empty:
                ZStack {
                    DriftLogicTheme.steelheadNavy.opacity(0.6)
                    ProgressView()
                        .tint(DriftLogicTheme.riverTeal)
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                ZStack {
                    DriftLogicTheme.steelheadNavy.opacity(0.6)
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.title2)
                        Text("Could not load photo")
                            .font(.caption)
                    }
                    .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.7))
                }
            @unknown default:
                Color.clear
            }
        }
    }
}

#Preview {
    FlyPatternGalleryView(
        flies: FlyRecommendationEngine.recommendedFlies(
            waterType: .smallStream,
            current: .slow,
            depth: .shallow,
            temp: .prime,
            turbidity: .clear,
            species: .trout,
            hatch: .notSure
        ),
        refreshKey: "preview"
    )
    .padding(.horizontal, 20)
}
