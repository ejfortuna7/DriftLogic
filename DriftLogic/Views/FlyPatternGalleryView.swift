import SwiftUI

struct FlyPatternGalleryView: View {
    let photos: [FlyPatternPhoto]

    var body: some View {
        if photos.isEmpty {
            Text("No fly photos matched this rig.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 16) {
                ForEach(photos) { photo in
                    FlyPatternPhotoCard(photo: photo)
                }
            }
        }
    }
}

private struct FlyPatternPhotoCard: View {
    let photo: FlyPatternPhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: photo.imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.tertiarySystemGroupedBackground))
                        ProgressView()
                    }
                    .frame(height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                case .failure:
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(height: 200)
                        .overlay {
                            VStack(spacing: 6) {
                                Image(systemName: "photo")
                                    .font(.title2)
                                Text("Could not load photo")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                @unknown default:
                    EmptyView()
                }
            }

            Text(photo.name)
                .font(.subheadline.weight(.semibold))

            Link("View on Wikimedia Commons", destination: photo.sourcePageURL)
                .font(.caption)

            Text("\(photo.license) · \(photo.credit)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    FlyPatternGalleryView(photos: FlyPatternPhotoLibrary.photos(forFlyRecommendation: "Parachute Adams, elk hair caddis"))
}
