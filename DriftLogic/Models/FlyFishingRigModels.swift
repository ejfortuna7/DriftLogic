import SwiftUI

// MARK: - Water & Target Enums

enum WaterType: String, CaseIterable, Identifiable {
    case smallStream = "Small Stream"
    case largeRiver = "Large River"
    case lakeStillwater = "Lake/Stillwater"
    case coastalFlats = "Coastal Flats"

    var id: String { rawValue }
}

enum CurrentSpeed: String, CaseIterable, Identifiable {
    case still = "Still"
    case slow = "Slow"
    case moderate = "Moderate"
    case fast = "Fast"

    var id: String { rawValue }
}

enum WaterDepth: String, CaseIterable, Identifiable {
    case shallow = "Shallow"
    case midDepth = "MidDepth"
    case deep = "Deep"

    var id: String { rawValue }
}

/// Water temperature bands aligned with common fly-fishing references
/// (trout feeding/stress thresholds, steelhead tributary behavior, bass activity charts, inshore redfish ranges).
enum WaterTemp: String, CaseIterable, Identifiable {
    case frigid = "Frigid"
    case cold = "Cold"
    case prime = "Prime"
    case warm = "Warm"
    case hot = "Hot"

    var id: String { rawValue }
}

enum Turbidity: String, CaseIterable, Identifiable {
    case clear = "Clear"
    case stained = "Stained"
    case muddy = "Muddy"

    var id: String { rawValue }
}

enum TargetSpecies: String, CaseIterable, Identifiable {
    case trout = "Trout"
    case bassPanfish = "Bass/Panfish"
    case steelhead = "Steelhead"
    case redfish = "Redfish"

    var id: String { rawValue }
}

// MARK: - Rig Recommendation

struct RigRecommendation: Equatable {
    let flyLine: String
    let leader: String
    let tippet: String
    let flyType: String
    let recommendedFlies: [RecommendedFly]
    let rationale: RigRationale
    let proTip: String
}

// MARK: - Decision Engine

final class RigDecisionEngine {

    static func generateRig(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies,
        hatch: ActiveHatch = .notSure
    ) -> RigRecommendation {
        let line = selectFlyLine(
            waterType: waterType,
            current: current,
            depth: depth,
            turbidity: turbidity,
            species: species
        )
        let leader = selectLeader(
            waterType: waterType,
            current: current,
            depth: depth,
            turbidity: turbidity,
            species: species
        )
        let tippet = selectTippet(
            depth: depth,
            current: current,
            turbidity: turbidity,
            temp: temp,
            species: species
        )
        let flies = FlyRecommendationEngine.recommendedFlies(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species,
            hatch: hatch
        )
        let fly = FlyRecommendationEngine.summary(from: flies)
        let tip = buildProTip(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species,
            hatch: hatch
        )
        let rationale = RigRationaleBuilder.build(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species,
            hatch: hatch
        )

        return RigRecommendation(
            flyLine: line,
            leader: leader,
            tippet: tippet,
            flyType: fly,
            recommendedFlies: flies,
            rationale: rationale,
            proTip: tip
        )
    }

    // MARK: Fly Line

    private static func selectFlyLine(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        turbidity: Turbidity,
        species: TargetSpecies
    ) -> String {
        switch species {
        case .steelhead:
            switch (depth, current) {
            case (.deep, _), (_, .fast), (_, .moderate) where depth != .shallow:
                return "Skagit or compact Scandi sink-tip system (T-8–T-11)"
            default:
                return "Switch rod floating line with light poly leader"
            }
        case .redfish:
            return waterType == .coastalFlats
                ? "Weight-forward saltwater floating (8–9 wt)"
                : "Intermediate clear tip for wind and chop"
        case .bassPanfish:
            if depth == .deep || current == .fast {
                return "Weight-forward floating with interchangeable sink tip"
            }
            return "Weight-forward floating (5–7 wt)"
        case .trout:
            break
        }

        switch (depth, current, turbidity) {
        case (.deep, .fast, _), (.deep, .moderate, .muddy), (_, .fast, .muddy):
            return "Sink-tip or full sinking line (Type III–VI)"
        case (.deep, _, _):
            return "Sink-tip line (10–15 ft Type II–III)"
        case (_, .still, .clear), (_, .slow, .clear) where depth == .shallow:
            return "Double-taper or delicate weight-forward floating"
        case (_, _, .muddy):
            return "Sink-tip or intermediate sinking line"
        default:
            switch waterType {
            case .lakeStillwater:
                return depth == .shallow ? "Floating line" : "Intermediate/full sink (Type II–IV)"
            case .coastalFlats:
                return "Saltwater weight-forward floating"
            case .smallStream:
                return "Weight-forward floating (3–5 wt)"
            case .largeRiver:
                return current == .fast ? "Sink-tip line" : "Weight-forward floating (5–6 wt)"
            }
        }
    }

    // MARK: Leader

    private static func selectLeader(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        turbidity: Turbidity,
        species: TargetSpecies
    ) -> String {
        switch species {
        case .steelhead:
            return "12–15 ft tapered steelhead leader or VersiLeader"
        case .redfish:
            return "9–12 ft fluorocarbon saltwater tapered leader"
        case .bassPanfish:
            return turbidity == .clear ? "7.5–9 ft nylon tapered" : "7.5 ft stiff butt leader"
        case .trout:
            break
        }

        switch (turbidity, current, depth) {
        case (.clear, .still, _), (.clear, .slow, .shallow):
            return "12–15 ft long nylon tapered leader"
        case (.clear, _, _):
            return "9–12 ft nylon tapered leader"
        case (.muddy, .fast, _), (.muddy, .moderate, _):
            return "6–7.5 ft short stiff leader (0X–2X butt)"
        case (.stained, _, .deep):
            return "7.5–9 ft fluorocarbon tapered leader"
        default:
            switch waterType {
            case .smallStream:
                return current == .fast ? "7.5 ft 4X tapered" : "9 ft 5X–6X tapered"
            case .largeRiver:
                return "9 ft 3X–4X tapered"
            case .lakeStillwater:
                return "10–12 ft fluorocarbon leader"
            case .coastalFlats:
                return "10 ft saltwater fluorocarbon tapered"
            }
        }
    }

    // MARK: Tippet

    private static func selectTippet(
        depth: WaterDepth,
        current: CurrentSpeed,
        turbidity: Turbidity,
        temp: WaterTemp,
        species: TargetSpecies
    ) -> String {
        switch species {
        case .steelhead:
            return turbidity == .clear ? "1X–2X fluorocarbon" : "0X–1X fluorocarbon"
        case .redfish:
            return "16–20 lb fluorocarbon shock tippet"
        case .bassPanfish:
            return "0X–3X nylon or fluorocarbon"
        case .trout:
            break
        }

        switch (turbidity, depth, current) {
        case (.clear, .shallow, .slow), (.clear, .shallow, .still):
            return temp.isFrigidOrCold ? "6X–7X fluorocarbon" : "5X–6X fluorocarbon"
        case (.clear, _, _):
            return temp.isFrigidOrCold ? "6X fluorocarbon" : "5X–6X fluorocarbon"
        case (.muddy, _, _), (_, .deep, .fast):
            return "2X–3X fluorocarbon or nylon"
        case (.stained, .deep, _), (.stained, _, .fast):
            return "3X–4X fluorocarbon"
        default:
            return temp.isWarmOrHot ? "4X–5X nylon" : "4X–5X fluorocarbon"
        }
    }

    // MARK: Pro Tip

    private static func buildProTip(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies,
        hatch: ActiveHatch
    ) -> String {
        if hatch.isSelected, hatch.influencesRig(species: species, turbidity: turbidity) {
            let hatchTip: String
            switch hatch {
            case .blueWingedOlive:
                hatchTip = "Match BWO size to naturals on the water—often #18–22. Overcast afternoons are prime."
            case .caddis:
                hatchTip = "Fish caddis at dusk; skitter adults in fast water, dead-drift pupa in seams."
            case .midge:
                hatchTip = "Midges are small—lengthen leader and watch for subtle takes in the film."
            case .stonefly:
                hatchTip = "Work stonefly patterns along bank seams and behind boulders."
            case .mayfly:
                hatchTip = "Compare your fly to duns on the water before changing patterns."
            case .terrestrial:
                hatchTip = "Plop terrestrials tight to banks; pause briefly before the first twitch."
            case .chironomid:
                hatchTip = "Adjust indicator depth until chironomids suspend where fish are feeding."
            case .notSure:
                hatchTip = ""
            }
            if !hatchTip.isEmpty {
                return hatchTip
            }
        }

        if species == .trout, temp == .hot {
            return "Water above ~75°F is poor for trout welfare. If you must fish, use only cool morning hours in spring seeps—otherwise switch target species or location."
        }
        if species == .trout, temp.troutElevatedStress {
            return "Above ~68°F trout stress quickly—fish at dawn, use barbless hooks, and keep fish wet. Prefer nymphs in aerated riffles over long fights on dries."
        }

        switch species {
        case .steelhead:
            if temp.isFrigidOrCold {
                return "In cold trib water, dead-drift eggs through the slow heart of pools—swing speed should be barely perceptible."
            }
            if temp.isPrime {
                return "Prime steelhead temps (~45–58°F): swing flies broad and slow across tailouts and riffle heads."
            }
            return "Focus on soft presentations at holding lies; dawn and overcast days outperform bright midday sun."
        case .redfish:
            if temp.isFrigidOrCold {
                return "Below ~70°F, blind-cast deeper mangrove edges and potholes—redfish leave skinny flats until afternoons warm."
            }
            return "Lead cruising fish by several feet and strip slowly on the flats. Match crab and shrimp colors to bottom tone."
        case .bassPanfish:
            if temp.isPrime || temp.isWarmOrHot {
                return "Work structure edges at dawn and dusk. Pause poppers two seconds before the first strip in warm shallows."
            }
            return "Cold bass need slow retrieves—tick bottom with a Woolly Bugger on a sink-tip near wood and rock."
        case .trout:
            break
        }

        switch (turbidity, depth, current) {
        case (.clear, .shallow, .slow), (.clear, .shallow, .still):
            return "Use a reach cast and slack-line drift to avoid drag on dries. Downsize tippet and lengthen leader if fish refuse."
        case (.muddy, .deep, .fast), (.muddy, _, .fast):
            return "Fish tight to banks and eddies where fish hold out of heavy flow. Use short, heavy rigs and animate flies with short strips."
        case (.stained, .midDepth, _), (.stained, .deep, _):
            return "Choose flies with contrast—hot spots, flash, or dark bodies. Dead-drift nymphs through seams, then lift at the end of the drift."
        case (_, .deep, _):
            return "Count flies down to the feeding zone and mend aggressively to keep depth. Vary sink time until you tick bottom occasionally."
        default:
            switch (waterType, temp) {
            case (.smallStream, _) where temp.isFrigidOrCold:
                return "Target slow tailouts and foam lines. Trout stack in softer water when metabolism drops below ~50°F."
            case (.lakeStillwater, _) where temp.isWarmOrHot:
                return "Retrieve leeches on an intermediate line with a figure-eight twist near weed beds. Watch for cruisers in the top two feet at dawn."
            case (.largeRiver, _) where current == .fast:
                return "High-stick or tight-line nymph through pocket water. Add split shot until the fly ticks occasionally without hanging up."
            case (.coastalFlats, _):
                return "Poling into position beats wading noise. Keep sun at your back and present flies ahead of moving fish."
            default:
                return "Adjust weight and leader length until the fly drifts naturally at fish depth. Match fly size to \(temp.fahrenheitRange) metabolism."
            }
        }
    }
}
