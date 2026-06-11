import SwiftUI

// MARK: - App model

/// Single source of truth for the user's condition selections.
@MainActor
final class AppModel: ObservableObject {
    /// Selected Steelhead Alley river — remembered across launches.
    @Published var river: River {
        didSet { UserDefaults.standard.set(river.id, forKey: "dl.selectedRiver") }
    }

    /// Whether the condition chips are expanded ("Customize conditions").
    @Published var conditionsExpanded = false

    init() {
        let savedID = UserDefaults.standard.string(forKey: "dl.selectedRiver")
        river = savedID.flatMap(SteelheadAlley.river(withID:)) ?? SteelheadAlley.defaultRiver
        species = .steelhead   // it's Steelhead Alley — default the target
    }

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
        species = .steelhead
        current = nil
        depth = nil
        temp = nil
        clarity = nil
        hatch = nil
        conditionsExpanded = false
    }

    /// Clear the water-driven conditions (used when switching rivers, so one
    /// river's live data never leaks onto another).
    func clearWaterConditions() {
        current = nil
        temp = nil
        clarity = nil
    }

    /// Force-apply the live readings (the banner button).
    func applyNowCast(current: CurrentSpeed?, clarity: WaterClarity?, temp: WaterTemp?) {
        if let current { self.current = current }
        if let clarity { self.clarity = clarity }
        if let temp { self.temp = temp }
    }

    /// Fill ONLY the unanswered conditions from the live gauge — runs after
    /// the user picks a method, so customizations are never stomped.
    /// Depth defaults to Mid (a gauge can't know where you're standing).
    func autoApply(from service: NowCastService) {
        if current == nil { current = service.suggestedCurrent }
        if clarity == nil { clarity = service.suggestedClarity }
        if temp == nil { temp = service.suggestedTemp }
        if depth == nil { depth = .mid }
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

                        riverPicker

                        NowCastBanner(service: nowCast) { current, clarity, temp in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                model.applyNowCast(current: current, clarity: clarity, temp: temp)
                            }
                        }

                        progressCard

                        gearSection

                        customizeToggle

                        if showConditionSections {
                            conditionSections
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

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
        .task { await nowCast.load(river: model.river) }
        .onChange(of: model.river) { _, river in
            // Fresh river, fresh water data — never carry one river's
            // conditions onto another.
            model.clearWaterConditions()
            nowCast.reload(for: river)
        }
        .onChange(of: model.method) { _, method in
            guard method != nil else { return }
            autoApplyConditions()
        }
        .onChange(of: nowCast.phase) { _, phase in
            guard phase == .loaded, model.method != nil else { return }
            autoApplyConditions()
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: model.isComplete)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: model.method)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: model.conditionsExpanded)
        .animation(.easeInOut(duration: 0.3), value: nowCast.phase)
    }

    /// River → gear → conditions auto-applied. Anything the gauge can't
    /// provide stays unanswered and the chips open so the user can finish.
    private func autoApplyConditions() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            if nowCast.phase == .loaded {
                model.autoApply(from: nowCast)
            }
            if !model.isComplete {
                model.conditionsExpanded = true
            }
        }
    }

    private var showConditionSections: Bool {
        model.conditionsExpanded || nowCast.phase == .unavailable || nowCast.phase == .failed
    }

    // MARK: River picker

    private var riverPicker: some View {
        Menu {
            ForEach(SteelheadAlley.groupedByState, id: \.state) { group in
                Section(group.state) {
                    ForEach(group.rivers) { river in
                        Button {
                            model.river = river
                        } label: {
                            if river.id == model.river.id {
                                Label(river.name, systemImage: "checkmark")
                            } else {
                                Text(river.name)
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "water.waves")
                    .imageScale(.medium)
                    .foregroundStyle(DriftLogicTheme.tealLight)
                VStack(alignment: .leading, spacing: 1) {
                    Text("RIVER")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(DriftLogicTheme.mist.opacity(0.5))
                    Text("\(model.river.name), \(model.river.state)")
                        .font(.headline)
                        .foregroundStyle(DriftLogicTheme.mist)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(DriftLogicTheme.tealLight)
            }
            .driftLogicCard(accent: DriftLogicTheme.tealLight)
        }
        .accessibilityLabel("Selected river: \(model.river.name), \(model.river.state). Tap to change.")
    }

    // MARK: Customize conditions toggle

    private var appliedSummary: String {
        let parts = [
            model.current.map(\.displayName),
            model.depth.map(\.displayName),
            model.temp.map(\.displayName),
            model.clarity.map(\.displayName),
        ].compactMap { $0 }
        return parts.isEmpty ? "No conditions set yet" : parts.joined(separator: " · ")
    }

    private var customizeToggle: some View {
        Button {
            DriftLogicHaptics.tap()
            model.conditionsExpanded.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.small)
                    .foregroundStyle(DriftLogicTheme.tealLight)
                VStack(alignment: .leading, spacing: 1) {
                    Text(model.conditionsExpanded ? "Customize conditions" : "Conditions")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DriftLogicTheme.mist)
                    if !model.conditionsExpanded {
                        Text(appliedSummary)
                            .font(.caption)
                            .foregroundStyle(DriftLogicTheme.mist.opacity(0.6))
                            .lineLimit(2)
                    }
                }
                Spacer()
                Image(systemName: model.conditionsExpanded ? "chevron.up" : "chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(DriftLogicTheme.tealLight)
            }
            .driftLogicCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            model.conditionsExpanded
                ? "Collapse condition pickers"
                : "Customize conditions. Currently: \(appliedSummary)"
        )
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
                Text("Steelhead Alley rig builder — fly · spin · center-pin")
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
        .accessibilityLabel("DriftLogic. Steelhead Alley rig builder.")
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

    private var gearSection: some View {
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
        }
    }

    private var conditionSections: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                ResultsView(result: result, method: scenario.method, river: model.river)
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
