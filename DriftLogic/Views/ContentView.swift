import SwiftUI

// MARK: - App model

/// Single source of truth for the user's condition selections.
@MainActor
final class AppModel: ObservableObject {
    /// Selected Steelhead Alley river — remembered across launches.
    @Published var river: River {
        didSet { UserDefaults.standard.set(river.id, forKey: "dl.selectedRiver") }
    }

    /// Whether the condition chips are expanded ("Modify conditions").
    @Published var conditionsExpanded = false

    /// Whether the user has tapped GO to reveal the recommended rig.
    /// Results stay hidden until this is set, then update live afterwards.
    @Published var showResults = false

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
        showResults = false
    }

    /// Clear the water-driven conditions (used when switching rivers, so one
    /// river's live data never leaks onto another).
    func clearWaterConditions() {
        current = nil
        temp = nil
        clarity = nil
    }

    /// Fill ONLY the unanswered conditions from the live gauge — runs as soon
    /// as the gauge loads, and never stomps a user's customizations.
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
    @StateObject private var sky = SkyService()

    private let resultsAnchor = "driftlogic.results"

    var body: some View {
        ZStack {
            DriftLogicTheme.screenBackground

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        if model.method != nil || model.showResults {
                            resetRow
                                .transition(.opacity)
                        }

                        riverPicker

                        NowCastBanner(service: nowCast, sky: sky)

                        gearSection

                        customizeToggle

                        if showConditionSections {
                            conditionSections
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        if !model.showResults {
                            goButton
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
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
                .onChange(of: model.showResults) { _, shown in
                    // GO drives the reveal now — scroll the freshly shown rig
                    // up into view.
                    if shown {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
                            proxy.scrollTo(resultsAnchor, anchor: .top)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await nowCast.load(river: model.river)
            await sky.load(for: model.river)
        }
        .onChange(of: model.river) { _, river in
            // Fresh river, fresh water data — never carry one river's
            // conditions onto another, and make them tap GO again.
            model.clearWaterConditions()
            model.showResults = false
            nowCast.reload(for: river)
            sky.reload(for: river)
        }
        .onChange(of: model.method) { _, method in
            guard method != nil else { return }
            autoApplyConditions()
        }
        .onChange(of: nowCast.phase) { _, phase in
            // Conditions populate the moment the river's gauge answers —
            // no button, no waiting for a gear pick.
            guard phase == .loaded else { return }
            autoApplyConditions()
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: model.isComplete)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: model.method)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: model.conditionsExpanded)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.showResults)
        .animation(.easeInOut(duration: 0.3), value: nowCast.phase)
    }

    /// River → conditions auto-applied. Anything the gauge can't provide
    /// stays unanswered; the chips pop open once the user is building
    /// (gear picked) and something is still missing.
    private func autoApplyConditions() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            if nowCast.phase == .loaded {
                model.autoApply(from: nowCast)
            }
            if model.method != nil, !model.isComplete {
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
                VStack(alignment: .leading, spacing: 2) {
                    Text("Modify conditions")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DriftLogicTheme.mist)
                    if !model.conditionsExpanded {
                        Text("Only if today's water differs from the live readings above")
                            .font(.caption)
                            .foregroundStyle(DriftLogicTheme.mist.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(appliedSummary)
                            .font(.caption2)
                            .foregroundStyle(DriftLogicTheme.tealLight.opacity(0.8))
                            .lineLimit(2)
                            .padding(.top, 1)
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
                : "Modify conditions, only if today's water differs from the live readings. Currently: \(appliedSummary)"
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

    // MARK: Reset

    /// Used only for the GO button's accessibility hint now that the progress
    /// card is gone — names what's still missing.
    private var remainingLabel: String {
        let missing = model.missingLabels
        if missing.isEmpty { return "Your rig is ready" }
        if missing.count == AppModel.requiredCount { return "\(missing.count) answers to go" }
        return "Still need: \(missing.joined(separator: " · "))"
    }

    /// A quiet top-right "Start over" control. Shows only once the angler has
    /// engaged (picked gear or built a rig) — it's out of the content flow,
    /// not parked in the middle of the screen.
    private var resetRow: some View {
        HStack {
            Spacer()
            Button {
                DriftLogicHaptics.tap()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    model.reset()
                }
            } label: {
                Label("Start over", systemImage: "arrow.counterclockwise")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DriftLogicTheme.salmon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start over — clear your selections")
        }
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

    // MARK: GO button

    /// The green "Build My Rig" call to action. Enabled once everything the
    /// engine needs is set (gear, species, and the auto-applied conditions);
    /// muted with a hint until then. Tapping it reveals the rig and scrolls.
    private var goButton: some View {
        Button {
            if model.isComplete {
                DriftLogicHaptics.ready()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    model.showResults = true
                }
            } else {
                // Not ready yet — nudge them to the missing pieces.
                DriftLogicHaptics.tap()
                if model.method != nil {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        model.conditionsExpanded = true
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: model.isComplete ? "figure.fishing" : "slider.horizontal.3")
                    .font(.headline.weight(.bold))
                Text(goButtonLabel)
                    .font(.headline.weight(.bold))
                if model.isComplete {
                    Image(systemName: "arrow.down")
                        .font(.subheadline.weight(.bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(
                model.isComplete ? DriftLogicTheme.navy : DriftLogicTheme.mist.opacity(0.6)
            )
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        model.isComplete
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        DriftLogicTheme.go,
                                        DriftLogicTheme.go.opacity(0.82),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.06))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                (model.isComplete ? DriftLogicTheme.go : DriftLogicTheme.teal)
                                    .opacity(0.5),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: model.isComplete ? DriftLogicTheme.go.opacity(0.35) : .clear,
                        radius: 12, x: 0, y: 5
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            model.isComplete
                ? "Build my rig"
                : "Finish the steps above to build your rig. \(remainingLabel)"
        )
    }

    private var goButtonLabel: String {
        if model.isComplete { return "Build My Rig" }
        if model.method == nil { return "Pick your gear to build your rig" }
        return "Set conditions to build your rig"
    }

    // MARK: Time-of-day bite window

    /// The species + hour advisory that sits atop the verified rig — what to
    /// throw *right now* given the light (e.g. bass on top at dawn, tubes at
    /// midday). Computed from the live sun times; never alters the rig itself.
    private func biteWindowCard(species: Species) -> some View {
        let advice = BiteWindowAdvisor.advice(
            species: species,
            phase: sky.lightPhase,
            steelheadOn: nowCast.steelheadOn
        )
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: advice.systemImage)
                    .font(.caption)
                    .foregroundStyle(DriftLogicTheme.gold)
                Text("RIGHT NOW · \(sky.lightPhase.displayName.uppercased())")
                    .font(.caption2.weight(.bold))
                    .tracking(0.6)
                    .foregroundStyle(DriftLogicTheme.gold)
                Spacer(minLength: 0)
            }
            Text(advice.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(DriftLogicTheme.mist)
            Text(advice.detail)
                .font(.footnote)
                .foregroundStyle(DriftLogicTheme.mist.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .driftLogicCard(accent: DriftLogicTheme.gold)
    }

    // MARK: Results

    @ViewBuilder
    private var resultsSection: some View {
        if model.showResults, let result = model.result, let scenario = model.scenario {
            VStack(alignment: .leading, spacing: 18) {
                biteWindowCard(species: scenario.species)
                ResultsView(result: result, method: scenario.method, river: model.river)
                VideoSectionView(videoIDs: result.videoIDs)
            }
            .padding(.top, 6)
            .transition(
                .opacity
                    .combined(with: .move(edge: .bottom))
                    .combined(with: .scale(scale: 0.97, anchor: .top))
            )
        }
    }
}

#Preview {
    ContentView()
}
