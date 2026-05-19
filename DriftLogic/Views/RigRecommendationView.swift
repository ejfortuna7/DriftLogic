import SwiftUI

struct RigRecommendationView: View {
    @State private var waterType: WaterType = .smallStream
    @State private var current: CurrentSpeed = .slow
    @State private var depth: WaterDepth = .shallow
    @State private var temp: WaterTemp = .prime
    @State private var turbidity: Turbidity = .clear
    @State private var species: TargetSpecies = .trout

    private var rig: RigRecommendation {
        RigDecisionEngine.generateRig(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species
        )
    }

    private var flyPhotos: [FlyPatternPhoto] {
        FlyPatternPhotoLibrary.photos(forFlyRecommendation: rig.flyType)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    conditionRow("Water", selection: $waterType, category: .water)
                    conditionRow("Current", selection: $current, category: .current)
                    conditionRow("Depth", selection: $depth, category: .depth)
                    conditionRow("Water temperature", selection: $temp, category: .waterTemperature, species: species)
                    conditionRow("Clarity", selection: $turbidity, category: .clarity)
                    conditionRow("Target", selection: $species, category: .target)
                } header: {
                    Text("Conditions")
                } footer: {
                    Text("Water temperature is measured in the river, lake, or flat—not the air temperature from a weather forecast. Tap Water temperature for help if you only know the weather outside.")
                }

                Section {
                    WhyThisRigView(rationale: rig.rationale)
                } header: {
                    Text("Why This Rig")
                } footer: {
                    Text("Summary for \(species.displayName) only. Gear details are in Your Rig below.")
                }

                Section("Your Rig") {
                    rigRow("Fly Line", rig.flyLine)
                    rigRow("Leader", rig.leader)
                    rigRow("Tippet", rig.tippet)
                    rigRow("Flies", rig.flyType)
                }

                Section {
                    Text(rig.proTip)
                        .font(.body)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Pro Tip")
                }

                Section {
                    FlyPatternGalleryView(photos: flyPhotos)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Flies on Your Rig")
                } footer: {
                    Text(
                        "Real fly photos from Wikimedia Commons. Images load from the internet and update when your recommended patterns change. Tap a link for source and license."
                    )
                }
            }
            .navigationTitle("DriftLogic")
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
                Spacer()
                Text(selection.wrappedValue.displayName)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func rigRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Selection screen (descriptions only here)

private struct ConditionSelectionView<T: FishingCondition>: View {
    @Binding var selection: T
    let category: ConditionCategory
    var targetSpecies: TargetSpecies?
    @State private var detailOption: T?

    var body: some View {
        List {
            if category == .waterTemperature {
                Section {
                    Text(WaterTemp.clarificationIntro)
                        .font(.subheadline)
                    Text(WaterTemp.estimatingWaterFromAir)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Not outside temperature")
                }
            }

            Section {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button {
                        selection = option
                        detailOption = option
                    } label: {
                        HStack {
                            Text(option.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            } footer: {
                if category == .waterTemperature {
                    Text("Choose the band that best matches the water where you will fish, not the air temperature on your phone.")
                } else {
                    Text(category.overview)
                }
            }

            if let detailOption {
                Section {
                    ConditionDetailContent(option: detailOption, targetSpecies: targetSpecies)
                } header: {
                    Text(category == .waterTemperature ? "Water: \(detailOption.displayName)" : detailOption.displayName)
                }
            }
        }
        .navigationTitle(category == .waterTemperature ? "Water temperature" : category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
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
                detailBlock("For your target (\(targetSpecies.displayName))", temp.speciesNotes(for: targetSpecies))
                detailBlock("Water vs. air temperature", WaterTemp.waterVersusAirNote)
            }
        }
        .textCase(nil)
    }

    private func detailBlock(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    RigRecommendationView()
}
