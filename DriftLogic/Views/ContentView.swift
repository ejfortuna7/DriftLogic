import SwiftUI

// MARK: - App model

/// Single source of truth for the user's condition selections.
@MainActor
final class AppModel: ObservableObject {
    @Published var method: Method? {
        didSet {
            // Hatch only applies to fly fishing — clear it when leaving fly.
            if method != .fly { hatch = nil }
        }
    }
    @Published var species: Species?
    @Published var current: CurrentSpeed?
    @Published var depth: WaterDepth?
    @Published var temp: WaterTemp?
    @Published var clarity: WaterClarity?
    /// Optional; only shown / meaningful when method == .fly.
    @Published var hatch: Hatch?

    static let requiredCount = 6

    var filledCount: Int {
        [
            method != nil,
            species != nil,
            current != nil,
            depth != nil,
            temp != nil,
            clarity != nil,
        ]
        .filter { $0 }
        .count
    }

    var isComplete: Bool { filledCount == Self.requiredCount }

    /// Names of the conditions still unanswered — drives "what's missing" UI.
    var missingLabels: [String] {
        var out: [String] = []
        if method == nil { out.append("Gear") }
        if species == nil { out.append("Species") }
        if current == nil { out.append("Current") }
        if depth == nil { out.append("Depth") }
        if temp == nil { out.append("Water Temp") }
        if clarity == nil { out.append("Clarity") }
        return out
    }

    var scenario: Scenario? {
        guard
            let method, let species, let current,
            let depth, let temp, let clarity
        else { return nil }
        return Scenario(
            method: method,
            species: species,
            current: current,
            depth: depth,
            temp: temp,
            clarity: clarity,
            hatch: method == .fly ? hatch : nil
        )
    }

    var result: RigResult? {
        scenario.map { DriftLogicEngine.recommend(for: $0) }
    }

    func reset() {
        method = nil
        species = nil
        current = nil
        depth = nil
        temp = nil
        clarity = nil
        hatch = nil
    }

    func applyNowCast(current: CurrentSpeed?, clarity: WaterClarity?, temp: WaterTemp?) {
        if let current { self.current = current }
        if let clarity { self.clarity = clarity }
        if let temp { self.temp = temp }
    }
}

// MARK: - Content view

struct ContentView: View {
    @StateObject private var model = AppModel()
    @StateObject private var nowCast = NowCastService()

    private let resultsAnchor = "driftlogic.results"

    var body: some View {
        ZStack {
            DriftLogicTheme.screenBackground

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        NowCastBanner(service: nowCast) { current, clarity, temp in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                model.applyNowCast(current: current, clarity: clarity, temp: temp)
                            }
                        }

                        progressCard

                        conditionSections

                        resultsSection
                            .id(resultsAnchor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                    // Pin the column to the scroll container's width. Without this,
                    // the content can be measured with a nil width proposal and lay
                    // out at its ideal (overflowing) width — seen on iOS 26 sim.
                    .containerRelativeFrame(.horizontal)
                }
                .scrollIndicators(.hidden)
                .onChange(of: model.isComplete) { _, complete in
                    if complete {
                        DriftLogicHaptics.ready()
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
                            proxy.scrollTo(resultsAnchor, anchor: .top)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await nowCast.load() }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: model.isComplete)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: model.method)
        .animation(.easeInOut(duration: 0.3), value: nowCast.phase)
    }

    // MARK: Header

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            // The art is painted as an overlay on a fixed-size base so the
            // image's intrinsic (very wide) size can never inflate the layout.
            Color.clear
                .frame(height: 190)
                .frame(maxWidth: .infinity)
                .overlay {
                    Image("SteelheadArtAW")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [
                            .clear,
                            DriftLogicTheme.navy.opacity(0.35),
                            DriftLogicTheme.navy.opacity(0.92),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("DriftLogic")
                    .font(DriftLogicTheme.scriptFont(size: 40))
                    .foregroundStyle(DriftLogicTheme.mist)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
                Text("Rocky River rig builder — fly · spinning · center-pin")
                    .font(.caption.weight(.medium))
                    .tracking(0.4)
                    .foregroundStyle(DriftLogicTheme.tealLight)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(DriftLogicTheme.teal.opacity(0.35), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("DriftLogic. Rocky River rig builder.")
    }

    // MARK: Progress

    private var remainingLabel: String {
        let missing = model.missingLabels
        if missing.isEmpty { return "Your rig is ready" }
        if missing.count == AppModel.requiredCount { return "\(missing.count) answers to go" }
        // Name what's missing so nobody is left hunting for the last chip.
        return "Still need: \(missing.joined(separator: " · "))"
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label {
                    Text(remainingLabel)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(
                            model.isComplete
                                ? DriftLogicTheme.tealLight
                                : DriftLogicTheme.mist.opacity(0.85)
                        )
                        .contentTransition(.numericText())
                } icon: {
                    Image(systemName: model.isComplete ? "checkmark.circle.fill" : "slider.horizontal.3")
                        .imageScale(.small)
                        .foregroundStyle(DriftLogicTheme.tealLight)
                }

                Spacer()

                if model.filledCount > 0 {
                    Button {
                        DriftLogicHaptics.tap()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            model.reset()
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DriftLogicTheme.salmon)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [DriftLogicTheme.teal, DriftLogicTheme.tealLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width
                                * CGFloat(model.filledCount)
                                / CGFloat(AppModel.requiredCount)
                        )
                }
            }
            .frame(height: 6)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: model.filledCount)
        }
        .driftLogicCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(model.filledCount) of \(AppModel.requiredCount) conditions set. \(remainingLabel)")
    }

    // MARK: Condition sections

    private var conditionSections: some View {
        VStack(alignment: .leading, spacing: 14) {
            conditionCard("Gear", systemImage: "figure.fishing") {
                ConditionChipGrid(
                    options: Array(Method.allCases),
                    selection: $model.method,
                    title: \.displayName
                )
            }

            conditionCard("Target Species", systemImage: "fish") {
                ConditionChipGrid(
                    options: Array(Species.allCases),
                    selection: $model.species,
                    title: \.displayName
                )
            }

            conditionCard("Current", systemImage: "water.waves") {
                ConditionChipGrid(
                    options: Array(CurrentSpeed.allCases),
                    selection: $model.current,
                    title: \.displayName
                )
            }

            conditionCard("Depth", systemImage: "arrow.down.to.line.compact") {
                ConditionChipGrid(
                    options: Array(WaterDepth.allCases),
                    selection: $model.depth,
                    title: \.displayName
                )
            }

            conditionCard("Water Temp", systemImage: "thermometer.medium") {
                ConditionChipGrid(
                    options: Array(WaterTemp.allCases),
                    selection: $model.temp,
                    title: \.displayName
                )
            }

            conditionCard("Clarity", systemImage: "eye") {
                ConditionChipGrid(
                    options: Array(WaterClarity.allCases),
                    selection: $model.clarity,
                    title: \.displayName
                )
            }

            if model.method == .fly {
                conditionCard("On the Water (optional)", systemImage: "ladybug") {
                    ConditionChipGrid(
                        options: Array(Hatch.allCases),
                        selection: $model.hatch,
                        title: \.displayName,
                        accent: { hatch in
                            hatch == Hatch.none
                                ? DriftLogicTheme.salmon
                                : DriftLogicTheme.teal
                        }
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.97)))
            }
        }
    }

    private func conditionCard<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
            } icon: {
                Image(systemName: systemImage)
                    .imageScale(.small)
            }
            .foregroundStyle(DriftLogicTheme.tealLight)

            content()
        }
        .driftLogicCard()
    }

    // MARK: Results

    @ViewBuilder
    private var resultsSection: some View {
        if let result = model.result, let scenario = model.scenario {
            VStack(alignment: .leading, spacing: 18) {
                ResultsView(result: result, method: scenario.method)
                VideoSectionView(videoIDs: result.videoIDs)
            }
            .padding(.top, 6)
            .transition(
                .opacity
                    .combined(with: .move(edge: .bottom))
                    .combined(with: .scale(scale: 0.97, anchor: .top))
            )
        } else {
            placeholderCard
                .transition(.opacity)
        }
    }

    private var placeholderCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "fish.fill")
                .font(.title)
                .foregroundStyle(DriftLogicTheme.teal.opacity(0.7))
            Text(
                model.filledCount == 0
                    ? "Answer the questions above and DriftLogic builds a complete Rocky River rig — gear, line, five picks, and a pro tip."
                    : "Almost there — still need: \(model.missingLabels.joined(separator: " · ")). Your rig appears here the moment the last one is set."
            )
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    DriftLogicTheme.teal.opacity(0.3),
                    style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                )
        }
    }
}

#Preview {
    ContentView()
}
