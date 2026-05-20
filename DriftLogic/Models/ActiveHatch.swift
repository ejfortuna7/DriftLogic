import Foundation

/// What the angler sees on the water right now—optional refinement for fly choice.
enum ActiveHatch: String, CaseIterable, Identifiable {
    case notSure = "Not sure"
    case blueWingedOlive = "Blue-Winged Olive"
    case caddis = "Caddis"
    case midge = "Midges"
    case stonefly = "Stonefly"
    case mayfly = "Mayfly / Drake"
    case terrestrial = "Terrestrials"
    case chironomid = "Chironomids"

    var id: String { rawValue }
}

extension ActiveHatch {

    var isSelected: Bool {
        self != .notSure
    }

    /// Hatch refinement matters most for selective fish in clearer water.
    func influencesRig(species: TargetSpecies, turbidity: Turbidity) -> Bool {
        guard isSelected else { return false }
        switch species {
        case .trout, .steelhead:
            return turbidity != .muddy
        case .bassPanfish:
            return self == .terrestrial || self == .caddis
        case .redfish:
            return false
        }
    }

    func flyRecommendation(
        species: TargetSpecies,
        waterType: WaterType,
        depth: WaterDepth,
        temp: WaterTemp,
        current: CurrentSpeed
    ) -> String? {
        guard isSelected else { return nil }

        switch (species, self) {
        case (.trout, .blueWingedOlive):
            return depth == .shallow && (current == .slow || current == .still)
                ? "BWO dry (#18–22), RS2 emerger, or parachute BWO—match rising fish"
                : "Beadhead BWO nymph (#18–20) or soft-hackle olive (#16–18) through seams"
        case (.trout, .caddis):
            return depth == .shallow
                ? "Elk hair caddis or X-Caddis (#14–18)—skitter or dead-drift at dusk"
                : "Caddis pupa or soft-hackle caddis (#14–16) under an indicator"
        case (.trout, .midge):
            return "Zebra midge, black beauty, or RS2 (#20–24) dead-drifted in film and tailouts"
        case (.trout, .stonefly):
            return current == .fast
                ? "Heavy rubber-leg stonefly or Pat's Rubber Legs (#6–10) tight to banks"
                : "Golden stone dry or beadhead stonefly nymph (#8–14)"
        case (.trout, .mayfly):
            return depth == .shallow
                ? "Parachute Adams, light Cahill, or parachute mayfly (#12–16)"
                : "Pheasant tail, hare's ear, or parachute emerger (#14–18)"
        case (.trout, .terrestrial):
            return "Foam hopper, beetle, or ant (#10–16) along undercut banks and grass lines"
        case (.trout, .chironomid):
            return waterType == .lakeStillwater
                ? "Chironomid pupa under indicator (#16–22) or slow retrieve near weed line"
                : "Small midge pupa or chironomid (#18–22) in calm eddies"

        case (.steelhead, .stonefly):
            return "Small dark stonefly nymph or rubber-leg (#8–12) dead-drifted through runs"
        case (.steelhead, .midge), (.steelhead, .blueWingedOlive):
            return "Small egg pattern or tiny soft hackle (#14–18) in softer water"
        case (.steelhead, .caddis):
            return "Soft-hackle or small swung caddis pupa (#12–14) through tailouts"

        case (.bassPanfish, .terrestrial):
            return "Poppers, foam frog, or hopper (#4–8) along weed edges and docks"
        case (.bassPanfish, .caddis):
            return "Damselfly nymph or slow-strip caddis pupa (#10–12) near lily pads"

        default:
            return nil
        }
    }

    func primaryPhotos() -> [FlyPatternPhoto] {
        switch self {
        case .notSure: return []
        case .blueWingedOlive: return [FlyPatternPhotoLibrary.bwoSparkleDun, FlyPatternPhotoLibrary.midgeEmerger]
        case .caddis: return [FlyPatternPhotoLibrary.elkHairCaddis, FlyPatternPhotoLibrary.hairWingedCaddis]
        case .midge: return [FlyPatternPhotoLibrary.biotMidge, FlyPatternPhotoLibrary.midgeEmerger]
        case .stonefly: return [FlyPatternPhotoLibrary.stoneflyNymph, FlyPatternPhotoLibrary.rubberLegsStone]
        case .mayfly: return [FlyPatternPhotoLibrary.parachuteAdams, FlyPatternPhotoLibrary.pheasantTail]
        case .terrestrial: return [FlyPatternPhotoLibrary.foamHopper, FlyPatternPhotoLibrary.foamAnt]
        case .chironomid: return [FlyPatternPhotoLibrary.chironomid, FlyPatternPhotoLibrary.biotMidge]
        }
    }

    func rationaleNote(species: TargetSpecies) -> String {
        switch self {
        case .notSure:
            return "No hatch selected—flies follow water conditions and target species only."
        case .blueWingedOlive:
            return "BWO active—size down (#18–22) and match olive bodies in clear water."
        case .caddis:
            return "Caddis active—elk hair or pupa patterns; fish faster water at dusk."
        case .midge:
            return "Midges active—long fine leader and tiny flies in film and slow seams."
        case .stonefly:
            return "Stoneflies active—heavy nymphs or buoyant dries in riffles and banks."
        case .mayfly:
            return "Mayfly activity—classic dries and emergers; match size to naturals on the water."
        case .terrestrial:
            return "Terrestrials on the water—hoppers and ants along banks and grass."
        case .chironomid:
            return "Chironomids active—indicator rigs or slow retrieves in still water."
        }
    }
}

// MARK: - FishingCondition (picker UI)

extension ActiveHatch: FishingCondition {
    var displayName: String { rawValue }

    var definition: String {
        switch self {
        case .notSure:
            return "You have not matched a specific insect hatch—DriftLogic uses water conditions and species only."
        case .blueWingedOlive:
            return "Olive mayflies (#18–22) in film or on the surface—common on cool, cloudy days."
        case .caddis:
            return "Tent-winged caddis adults or pupa rising—often at dusk along riffles."
        case .midge:
            return "Tiny dipterans clustering or in the surface film—especially winter and spring."
        case .stonefly:
            return "Large stonefly adults or nymphs—salmonflies, golden stones, or yellow sallies."
        case .mayfly:
            return "Pale or dark mayfly duns and spinners—Adams-class patterns and emergers."
        case .terrestrial:
            return "Grasshoppers, beetles, or ants blown onto the water—summer banks."
        case .chironomid:
            return "Lake or pond midges (#16–22)—often under an indicator or slow retrieve."
        }
    }

    var howToIdentify: String {
        switch self {
        case .notSure:
            return "No obvious insects or rises you can match—leave this on Not sure."
        case .blueWingedOlive:
            return "Small olive duns on the water, olive risers, or BWO in a seine sample."
        case .caddis:
            return "Adults skittering on the surface, pupa in the film, or caddis in a kick sample."
        case .midge:
            return "Clumps of tiny flies, pinhead rises, or midges in back-eddies and foam."
        case .stonefly:
            return "Large fluttering adults, shucks on rocks, or big nymphs under stones."
        case .mayfly:
            return "Duns or spinners on the water, sailboat rises, or mayflies in a seine."
        case .terrestrial:
            return "Hoppers or ants on the water after wind, or fish slashing near banks."
        case .chironomid:
            return "Midges hovering over still water, chironomid pupa in a lake sample, or steady sipping rises."
        }
    }

    var rigImpact: String {
        switch self {
        case .notSure:
            return "Fly choice follows clarity, depth, temperature, and target only."
        default:
            return "Narrows recommended flies and photos to patterns that imitate this hatch."
        }
    }

    var shortDescriptor: String {
        switch self {
        case .notSure: return "conditions-based flies only"
        default: return "refines fly match"
        }
    }
}
