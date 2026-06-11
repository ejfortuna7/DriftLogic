import SwiftUI
import SafariServices

/// "Watch the Technique" — a horizontal rail of five video cards.
/// Tapping a card opens the video in an in-app Safari sheet.
struct VideoSectionView: View {
    let videoIDs: [String]

    @State private var selectedVideo: VideoInfo?

    private var videos: [VideoInfo] {
        videoIDs.map { VideoLibrary.info(for: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Watch the Technique")
                    .font(.subheadline.weight(.bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
            } icon: {
                Image(systemName: "play.rectangle.fill")
                    .imageScale(.small)
            }
            .foregroundStyle(DriftLogicTheme.salmon)
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(videos) { video in
                        videoCard(video)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        .sheet(item: $selectedVideo) { video in
            SafariView(url: video.watchURL)
                .ignoresSafeArea()
        }
    }

    private func videoCard(_ video: VideoInfo) -> some View {
        Button {
            DriftLogicHaptics.tap()
            selectedVideo = video
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                thumbnail(for: video)

                Text(video.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DriftLogicTheme.mist)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)

                Text(video.channel)
                    .font(.caption2)
                    .foregroundStyle(DriftLogicTheme.tealLight.opacity(0.8))
                    .lineLimit(1)
            }
            .frame(width: 220, alignment: .leading)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(DriftLogicTheme.teal.opacity(0.25), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(video.title), \(video.channel). Plays video.")
    }

    private func thumbnail(for video: VideoInfo) -> some View {
        AsyncImage(url: video.thumbnailURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                ZStack {
                    DriftLogicTheme.navy.opacity(0.6)
                    Image(systemName: "fish")
                        .font(.title2)
                        .foregroundStyle(DriftLogicTheme.teal.opacity(0.5))
                }
            }
        }
        .frame(width: 200, height: 112)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            ZStack {
                Circle()
                    .fill(.black.opacity(0.55))
                    .frame(width: 40, height: 40)
                Image(systemName: "play.fill")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .offset(x: 1)
            }
        }
    }
}

// MARK: - In-app Safari

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredBarTintColor = UIColor(DriftLogicTheme.navy)
        controller.preferredControlTintColor = UIColor(DriftLogicTheme.tealLight)
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
