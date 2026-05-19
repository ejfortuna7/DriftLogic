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

enum WaterTemp: String, CaseIterable, Identifiable {
    case cold = "Cold"
    case cool = "Cool"
    case warm = "Warm"

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
        species: TargetSpecies
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
        let fly = selectFlyType(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species
        )
        let tip = buildProTip(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species
        )

        return RigRecommendation(
            flyLine: line,
            leader: leader,
            tippet: tippet,
            flyType: fly,
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
            return temp == .cold ? "6X–7X fluorocarbon" : "5X–6X fluorocarbon"
        case (.clear, _, _):
            return "5X–6X fluorocarbon"
        case (.muddy, _, _), (_, .deep, .fast):
            return "2X–3X fluorocarbon or nylon"
        case (.stained, .deep, _), (.stained, _, .fast):
            return "3X–4X fluorocarbon"
        default:
            return temp == .warm ? "4X–5X nylon" : "4X–5X fluorocarbon"
        }
    }

    // MARK: Fly Type

    private static func selectFlyType(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies
    ) -> String {
        switch species {
        case .steelhead:
            switch (temp, turbidity) {
            case (.cold, _), (.cool, .clear):
                return "Egg patterns, small stonefly nymphs, or swung intruders"
            case (_, .muddy):
                return "Large dark intruders or rubber-leg stonefly (#2–6)"
            default:
                return "Spey flies, soft hackles, or egg-sucking leeches"
            }
        case .redfish:
            return turbidity == .clear
                ? "Clouser minnow, crab, or shrimp (#4–2)"
                : "Chartreuse/white Clouser or spoon fly"
        case .bassPanfish:
            switch (depth, temp) {
            case (.shallow, .warm):
                return "Poppers, foam ants, or damselfly dries"
            case (.deep, _):
                return "Woolly Bugger, Clouser, or crayfish (#6–2)"
            default:
                return "Woolly Bugger or conehead streamer"
            }
        case .trout:
            break
        }

        switch (turbidity, depth, current, temp) {
        case (.clear, .shallow, .slow, _), (.clear, .shallow, .still, _):
            return temp == .warm
                ? "Parachute Adams, elk hair caddis, or terrestrials (#14–18)"
                : "Blue-winged olive or midge dry (#18–22)"
        case (.clear, _, .slow, .cold), (.clear, _, .still, .cold):
            return "Zebra midge, RS2, or small emerger (#18–22)"
        case (.muddy, _, _, _), (_, .deep, .fast, _):
            return "Large rubber-leg stonefly, Woolly Bugger, or articulated streamer (#4–8)"
        case (.stained, .deep, _, _), (.stained, _, .moderate, _):
            return "Beadhead prince, Pat's Rubber Legs, or conehead streamer (#8–12)"
        case (_, .midDepth, _, .cool):
            return "Pheasant tail, hare's ear, or soft hackle (#14–18)"
        default:
            switch waterType {
            case .smallStream:
                return "High-riding dry or small attractor nymph (#14–16)"
            case .largeRiver:
                return current == .fast ? "Heavy stonefly nymph (#6–10)" : "Dry-dropper (caddis + beadhead)"
            case .lakeStillwater:
                return depth == .shallow ? "Callibaetis or chironomid (#14–16)" : "Leach or damsel nymph (#10–12)"
            case .coastalFlats:
                return "Shrimp or crab pattern (#6–4)"
            }
        }
    }

    // MARK: Pro Tip

    private static func buildProTip(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies
    ) -> String {
        switch species {
        case .steelhead:
            return "Focus on soft presentations at holding lies; swing flies slow and broad across the current. Dawn and overcast days often outperform bright midday sun."
        case .redfish:
            return "Lead cruising fish by several feet and strip slowly on the flats. Match crab and shrimp colors to bottom tone—lighter sand, darker grass."
        case .bassPanfish:
            return "Work structure edges at dawn and dusk. In warm shallows, pause poppers two seconds before the first strip to draw aggressive topwater strikes."
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
            case (.smallStream, .cold):
                return "Target slow tailouts and foam lines. Trout stack in softer water when metabolism drops in cold temps."
            case (.lakeStillwater, .warm):
                return "Retrieve leeches on an intermediate line with a figure-eight hand twist near weed beds. Watch for cruising fish in the top two feet at dawn."
            case (.largeRiver, _) where current == .fast:
                return "High-stick or tight-line nymph through pocket water. Add split shot until the fly ticks occasionally without hanging up."
            case (.coastalFlats, _):
                return "Poling into position beats wading noise. Keep sun at your back and present flies ahead of moving fish, not on top of them."
            default:
                return "Adjust weight and leader length until the fly drifts naturally at fish depth. Observe rise forms and surface insects before changing patterns."
            }
        }
    }
}
