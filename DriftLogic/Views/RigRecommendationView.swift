import SwiftUI

struct RigRecommendationView: View {
    @State private var waterType: WaterType = .smallStream
    @State private var current: CurrentSpeed = .slow
    @State private var depth: WaterDepth = .shallow
    @State private var temp: WaterTemp = .cool
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

    var body: some View {
        NavigationStack {
            Form {
                Section("Conditions") {
                    picker("Water", selection: $waterType, options: WaterType.allCases)
                    picker("Current", selection: $current, options: CurrentSpeed.allCases)
                    picker("Depth", selection: $depth, options: WaterDepth.allCases)
                    picker("Temperature", selection: $temp, options: WaterTemp.allCases)
                    picker("Clarity", selection: $turbidity, options: Turbidity.allCases)
                    picker("Target", selection: $species, options: TargetSpecies.allCases)
                }

                Section("Your Rig") {
                    rigRow("Fly Line", rig.flyLine)
                    rigRow("Leader", rig.leader)
                    rigRow("Tippet", rig.tippet)
                    rigRow("Flies", rig.flyType)
                }

                Section("Pro Tip") {
                    Text(rig.proTip)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("DriftLogic")
        }
    }

    private func picker<T: Hashable & Identifiable>(
        _ label: String,
        selection: Binding<T>,
        options: [T]
    ) -> some View where T: RawRepresentable, T.RawValue == String {
        Picker(label, selection: selection) {
            ForEach(options) { option in
                Text(option.rawValue).tag(option)
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

#Preview {
    RigRecommendationView()
}
