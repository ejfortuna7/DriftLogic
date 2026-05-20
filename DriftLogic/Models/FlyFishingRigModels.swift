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
        let fly = selectFlyType(
            waterType: waterType,
            current: current,
            depth: depth,
            temp: temp,
            turbidity: turbidity,
            species: species,
            hatch: hatch
        )
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

    // MARK: Fly Type

    private static func selectFlyType(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies,
        hatch: ActiveHatch
    ) -> String {
        if hatch.influencesRig(species: species, turbidity: turbidity),
           let hatchFly = hatch.flyRecommendation(
               species: species,
               waterType: waterType,
               depth: depth,
               temp: temp,
               current: current
           ) {
            return hatchFly
        }

        switch species {
        case .steelhead:
            switch (temp, turbidity) {
            case (.frigid, _), (.cold, _):
                return "Egg patterns, small stonefly nymphs (#10–14), or micro intruders—dead-drifted slow"
            case (.prime, _), (.warm, .clear):
                return "Spey flies, swung intruders, or egg-sucking leeches (#4–8)"
            case (_, .muddy):
                return "Large dark intruders or rubber-leg stonefly (#2–6)"
            case (.hot, _):
                return "Dark swung streamers and compact intruders in shaded runs (#2–6)"
            default:
                return "Soft hackles, egg patterns, or compact Spey patterns (#6–10)"
            }
        case .redfish:
            switch temp {
            case .frigid, .cold:
                return turbidity == .clear
                    ? "Clouser or shrimp (#4–2) on intermediate tip—deeper potholes and channels"
                    : "Chartreuse/white Clouser (#2–1) with slow strip"
            case .hot:
                return turbidity == .clear
                    ? "Crab or shrimp (#4–2)—prioritize dawn flood tides and grass edges"
                    : "Chartreuse/white Clouser with loud strip near deeper mangrove shade"
            default:
                return turbidity == .clear
                    ? "Clouser minnow, crab, or shrimp (#4–2)"
                    : "Chartreuse/white Clouser or spoon fly"
            }
        case .bassPanfish:
            switch (depth, temp) {
            case (.shallow, .prime), (.shallow, .warm), (.shallow, .hot):
                return "Poppers, foam ants, or damselfly dries (#6–12)"
            case (_, .frigid), (_, .cold):
                return "Slow Woolly Bugger or jig-style streamer (#6–10) along deep banks"
            case (.deep, _):
                return "Woolly Bugger, Clouser, or crayfish (#6–2)"
            default:
                return "Woolly Bugger or conehead streamer with pause-strip retrieve"
            }
        case .trout:
            break
        }

        switch (turbidity, depth, current, temp) {
        case (.clear, .shallow, .slow, .hot), (.clear, .shallow, .still, .hot):
            return "Large hopper or damselfly dry at first light only (#8–12)—avoid midday trout stress"
        case (.clear, .shallow, .slow, .warm), (.clear, .shallow, .still, .warm):
            return "Parachute Adams, elk hair caddis, or terrestrials (#14–18)—fish early and late"
        case (.clear, .shallow, .slow, .prime), (.clear, .shallow, .still, .prime):
            return "Parachute Adams, elk hair caddis, or BWO dry (#14–18)"
        case (.clear, .shallow, .slow, _), (.clear, .shallow, .still, _):
            return "Blue-winged olive or midge dry (#18–22)"
        case (.clear, _, .slow, _), (.clear, _, .still, _) where temp.isFrigidOrCold:
            return "Zebra midge, RS2, or small emerger (#18–22)"
        case (.muddy, _, _, _), (_, .deep, .fast, _):
            return "Large rubber-leg stonefly, Woolly Bugger, or articulated streamer (#4–8)"
        case (.stained, .deep, _, _), (.stained, _, .moderate, _):
            return "Beadhead prince, Pat's Rubber Legs, or conehead streamer (#8–12)"
        case (_, .midDepth, _, .prime), (_, .midDepth, _, .warm):
            return "Pheasant tail, hare's ear, or soft hackle (#14–18)"
        case (_, .midDepth, _, _) where temp.isFrigidOrCold:
            return "Beadhead pheasant tail, zebra midge, or egg (#16–22)"
        default:
            switch waterType {
            case .smallStream:
                return temp.isWarmOrHot
                    ? "Foam beetle or hopper in shade (#12–14)"
                    : "High-riding dry or small attractor nymph (#14–16)"
            case .largeRiver:
                return current == .fast ? "Heavy stonefly nymph (#6–10)" : "Dry-dropper (caddis + beadhead)"
            case .lakeStillwater:
                if temp.isFrigidOrCold {
                    return "Chironomid under indicator (#18–22) or slow leech on intermediate"
                }
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
