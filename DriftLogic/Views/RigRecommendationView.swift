import SwiftUI

struct RigRecommendationView: View {
    @State private var waterType: WaterType = .smallStream
    @State private var current: CurrentSpeed = .slow
    @State private var depth: WaterDepth = .shallow
    @State private var temp: WaterTemp = .prime
    @State private var turbidity: Turbidity = .clear
    @State private var species: TargetSpecies = .trout
    @State private var hatch: ActiveHatch = .notSure

    private var rig: RigRecommendation {
        RigDecisionEngine.generateRig(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species,
            hatch: hatch
        )
    }

    private var flyPhotos: [FlyPatternPhoto] {
        FlyPatternPhotoLibrary.photos(forFlyRecommendation: rig.flyType, hatch: hatch)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DriftLogicTitleView(size: 44, showTagline: true)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                }

                Section {
                    conditionRow("Water", selection: $waterType, category: .water)
                    conditionRow("Current", selection: $current, category: .current)
                    conditionRow("Depth", selection: $depth, category: .depth)
                    conditionRow("Water temp", selection: $temp, category: .waterTemperature, species: species)
                    conditionRow("Clarity", selection: $turbidity, category: .clarity)
                    conditionRow("Target", selection: $species, category: .target)
                    conditionRow("On the water", selection: $hatch, category: .onTheWater, species: species)
                } header: {
                    Text("Conditions")
                        .driftLogicSectionHeader()
                } footer: {
                    Text("Water temp is in the river or lake, not the forecast. On the water refines flies—leave Not sure if nothing's obvious.")
                        .driftLogicSectionFooter()
                }

                Section {
                    WhyThisRigView(rationale: rig.rationale)
                } header: {
                    Text("Why This Rig")
                        .driftLogicSectionHeader()
                } footer: {
                    Text("Summary for \(species.displayName) only. Gear details are in Your Rig below.")
                        .driftLogicSectionFooter()
                }

                Section {
                    rigRow("Fly Line", rig.flyLine)
                    rigRow("Leader", rig.leader)
                    rigRow("Tippet", rig.tippet)
                    rigRow("Flies", rig.flyType)
                } header: {
                    Text("Your Rig")
                        .driftLogicSectionHeader()
                }

                Section {
                    Text(rig.proTip)
                        .font(.subheadline)
                        .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.88))
                } header: {
                    Text("Pro Tip")
                        .driftLogicSectionHeader()
                }

                Section {
                    FlyPatternGalleryView(photos: flyPhotos)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Flies on Your Rig")
                        .driftLogicSectionHeader()
                } footer: {
                    Text(
                        "Real fly photos from Wikimedia Commons. Images load from the internet and update when your recommended patterns change. Tap a link for source and license."
                    )
                    .driftLogicSectionFooter()
                }
            }
            .driftLogicFormStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    DriftLogicTitleView(size: 28, showTagline: false)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .driftLogicNavigationChrome()
        }
    }

    private func conditionRow<T: FishingCondition>(
        _ title: String,
        selection: Binding<T>,
        category: ConditionCategory,
        species: TargetSpecies? = nil
    ) -> some View {
        NavigationLink {
            ConditionSelectionView(selection: selection, category: category, targetSpecies: species)
        } label: {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Text(conditionValueLabel(selection.wrappedValue))
                    .foregroundStyle(DriftLogicTheme.riverTeal.opacity(0.95))
                    .multilineTextAlignment(.trailing)
            }
        }
        .driftLogicListRow()
    }

    private func conditionValueLabel<T: FishingCondition>(_ value: T) -> String {
        if let temp = value as? WaterTemp {
            return "\(temp.displayName) · \(temp.shortDescriptor)"
        }
        return value.displayName
    }

    private func rigRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DriftLogicTheme.salmonPink.opacity(0.9))
            Text(value)
                .font(.body)
                .foregroundStyle(DriftLogicTheme.riverMist)
        }
        .padding(.vertical, 2)
        .driftLogicListRow()
    }
}

// MARK: - Selection screen (descriptions only here)

private struct ConditionSelectionView<T: FishingCondition>: View {
    @Binding var selection: T
    let category: ConditionCategory
    var targetSpecies: TargetSpecies?
    @State private var detailOption: T?
    @State private var showAirTempHints = false

    var body: some View {
        List {
            Section {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button {
                        selection = option
                        detailOption = option
                    } label: {
                        HStack {
                            if let temp = option as? WaterTemp {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(temp.displayName)
                                        .foregroundStyle(DriftLogicTheme.riverMist)
                                    Text(temp.shortDescriptor)
                                        .font(.caption)
                                        .foregroundStyle(DriftLogicTheme.riverTeal.opacity(0.9))
                                }
                            } else {
                                Text(option.displayName)
                                    .foregroundStyle(DriftLogicTheme.riverMist)
                            }
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DriftLogicTheme.salmonPink)
                            }
                        }
                    }
                    .driftLogicListRow()
                }
            } footer: {
                if category == .waterTemperature {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.overview)
                            .driftLogicSectionFooter()
                        DisclosureGroup("Only know air temp?", isExpanded: $showAirTempHints) {
                            Text(WaterTemp.estimatingWaterFromAir)
                                .font(.subheadline)
                                .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.75))
                                .padding(.top, 4)
                        }
                        .font(.subheadline)
                        .tint(DriftLogicTheme.riverTeal)
                    }
                } else {
                    Text(category.overview)
                        .driftLogicSectionFooter()
                }
            }

            if let detailOption {
                Section {
                    ConditionDetailContent(option: detailOption, targetSpecies: targetSpecies)
                } header: {
                    Text(waterTempDetailHeader(detailOption))
                        .driftLogicSectionHeader()
                }
                .driftLogicListRow()
            }
        }
        .driftLogicFormStyle()
        .navigationTitle(category == .waterTemperature ? "Water temp" : category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .driftLogicNavigationChrome()
    }

    private func waterTempDetailHeader(_ option: T) -> String {
        guard let temp = option as? WaterTemp else { return option.displayName }
        return "\(temp.displayName) · \(temp.shortDescriptor)"
    }
}

private struct ConditionDetailContent<T: FishingCondition>: View {
    let option: T
    var targetSpecies: TargetSpecies?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            detailBlock("What it means", option.definition)
            detailBlock("How to tell", option.howToIdentify)
            detailBlock("Effect on your rig", option.rigImpact)
            if let targetSpecies, let temp = option as? WaterTemp {
                detailBlock("For \(targetSpecies.displayName)", temp.speciesNotes(for: targetSpecies))
            }
            if let targetSpecies, let hatch = option as? ActiveHatch, hatch != .notSure {
                let applies = hatch.influencesRig(species: targetSpecies, turbidity: .clear)
                detailBlock(
                    "For your target (\(targetSpecies.displayName))",
                    applies
                        ? hatch.rationaleNote(species: targetSpecies)
                        : "This hatch refines flies best for trout and steelhead in clearer water, or terrestrials for bass. Muddy water or saltwater targets rely on conditions alone."
                )
            }
        }
        .textCase(nil)
    }

    private func detailBlock(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DriftLogicTheme.salmonPink.opacity(0.9))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.88))
        }
    }
}

#Preview {
    RigRecommendationView()
}
