import Foundation

/// One concrete pattern to tie and photograph—not a vague category string.
struct RecommendedFly: Identifiable, Equatable {
    let name: String
    let sizeNote: String
    let tactic: String
    let photo: FlyPatternPhoto

    var id: String { "\(name)-\(sizeNote)" }

    var displayLine: String {
        sizeNote.isEmpty ? name : "\(name) \(sizeNote)"
    }
}

enum FlyRecommendationEngine {

    static func recommendedFlies(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies,
        hatch: ActiveHatch
    ) -> [RecommendedFly] {
        if hatch.influencesRig(species: species, turbidity: turbidity),
           let hatchFlies = hatch.recommendedFlies(
               species: species,
               waterType: waterType,
               depth: depth,
               temp: temp,
               current: current
           ) {
            return hatchFlies
        }

        switch species {
        case .trout:
            return troutFlies(
                waterType: waterType,
                current: current,
                depth: depth,
                temp: temp,
                turbidity: turbidity
            )
        case .steelhead:
            return steelheadFlies(
                waterType: waterType,
                current: current,
                depth: depth,
                temp: temp,
                turbidity: turbidity
            )
        case .bassPanfish:
            return bassFlies(
                waterType: waterType,
                current: current,
                depth: depth,
                temp: temp,
                turbidity: turbidity
            )
        case .redfish:
            return redfishFlies(temp: temp, turbidity: turbidity, waterType: waterType)
        }
    }

    static func summary(from flies: [RecommendedFly]) -> String {
        flies.map(\.displayLine).joined(separator: " · ")
    }

    // MARK: - Builders

    private static func fly(
        _ photo: FlyPatternPhoto,
        size: String,
        tactic: String = ""
    ) -> RecommendedFly {
        RecommendedFly(name: photo.name, sizeNote: size, tactic: tactic, photo: photo)
    }

    // MARK: - Trout

    private static func troutFlies(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity
    ) -> [RecommendedFly] {
        let p = FlyPatternPhotoLibrary.self

        if turbidity == .muddy {
            return [
                fly(p.rubberLegsStone, size: "#4–8", tactic: "Dead-drift tight to soft banks"),
                fly(p.woollyBugger, size: "#6–10", tactic: "Slow swing through stained lanes"),
                fly(p.largeStreamer, size: "#2–6", tactic: "Strip-pause in deeper runs"),
            ]
        }

        if temp == .hot {
            return [
                fly(p.foamHopper, size: "#8–12", tactic: "Dawn only along shaded banks"),
                fly(p.foamAnt, size: "#14–16", tactic: "Undercut grass lines at first light"),
                fly(p.pheasantTail, size: "#16–18", tactic: "Deep aerated riffle if you must fish midday"),
            ]
        }

        if temp == .frigid || temp == .cold {
            switch (depth, current) {
            case (.deep, _), (_, .fast):
                return [
                    fly(p.sanJuanWorm, size: "#14–16", tactic: "Eggs in soft tailouts"),
                    fly(p.stoneflyNymph, size: "#8–12", tactic: "Heavy dead-drift through deep slots"),
                    fly(p.biotMidge, size: "#20–24", tactic: "Zebra midge in slow inside seams"),
                ]
            default:
                return [
                    fly(p.biotMidge, size: "#20–24", tactic: "Film and tailout drifts"),
                    fly(p.midgeEmerger, size: "#20–22", tactic: "RS2 in shallow soft water"),
                    fly(p.sanJuanWorm, size: "#16–18", tactic: "Egg pattern in slower water"),
                ]
            }
        }

        if waterType == .lakeStillwater {
            if depth == .deep || temp == .warm {
                return [
                    fly(p.eggSuckingLeech, size: "#10–12", tactic: "Slow retrieve on intermediate"),
                    fly(p.chironomid, size: "#16–20", tactic: "Indicator rig over weed drop-offs"),
                    fly(p.softHackle, size: "#14–16", tactic: "Count-down and retrieve near structure"),
                ]
            }
            return [
                fly(p.chironomid, size: "#16–22", tactic: "Indicator at weed line"),
                fly(p.bwoSparkleDun, size: "#14–18", tactic: "Callibaetis-style dry on calm flats"),
                fly(p.softHackle, size: "#14–16", tactic: "Damsel nymph slow strip"),
            ]
        }

        if waterType == .largeRiver {
            switch (current, depth, turbidity) {
            case (.fast, _, _):
                return [
                    fly(p.rubberLegsStone, size: "#6–10", tactic: "Heavy nymph along bank seams"),
                    fly(p.stoneflyNymph, size: "#8–12", tactic: "Pat's Rubber Legs in fast runs"),
                    fly(p.woollyBugger, size: "#6–8", tactic: "Swing through tailouts"),
                ]
            case (_, .deep, .stained):
                return [
                    fly(p.princeNymph, size: "#10–14", tactic: "Beadhead through ledges"),
                    fly(p.coneheadBugger, size: "#6–8", tactic: "Deep swing on sink tip"),
                    fly(p.haresEar, size: "#12–16", tactic: "Dropper under indicator"),
                ]
            default:
                return [
                    fly(p.hairWingedCaddis, size: "#14–16", tactic: "Dry-dropper dry"),
                    fly(p.princeNymph, size: "#12–16", tactic: "Beadhead dropper"),
                    fly(p.elkHairCaddis, size: "#14–16", tactic: "Evening skitter at dusk"),
                ]
            }
        }

        if waterType == .smallStream {
            switch (turbidity, depth, current, temp) {
            case (.clear, .shallow, .slow, .prime), (.clear, .shallow, .still, .prime):
                return [
                    fly(p.parachuteAdams, size: "#14–18", tactic: "Match rising fish in pools"),
                    fly(p.elkHairCaddis, size: "#14–16", tactic: "Dead-drift at dusk"),
                    fly(p.pheasantTail, size: "#16–18", tactic: "Dropper in riffle heads"),
                ]
            case (.clear, .shallow, _, .warm):
                return [
                    fly(p.foamHopper, size: "#10–14", tactic: "Banks and grass lines"),
                    fly(p.foamAnt, size: "#14–16", tactic: "Under overhangs"),
                    fly(p.elkHairCaddis, size: "#14–16", tactic: "Early and late caddis"),
                ]
            case (.stained, _, .moderate, _), (.stained, .midDepth, _, _):
                return [
                    fly(p.princeNymph, size: "#12–16", tactic: "Beadhead through stained seams"),
                    fly(p.woollyBugger, size: "#8–10", tactic: "Slow swing"),
                    fly(p.stimulator, size: "#10–12", tactic: "High-visibility attractor dry"),
                ]
            default:
                return [
                    fly(p.stimulator, size: "#12–14", tactic: "Bushy dry in pocket water"),
                    fly(p.haresEar, size: "#14–16", tactic: "General nymph"),
                    fly(p.softHackle, size: "#14–16", tactic: "Swing through soft runs"),
                ]
            }
        }

        // Trout: general river / remaining combos
        switch (turbidity, depth, current, temp) {
        case (.clear, .shallow, .slow, .warm), (.clear, .shallow, .still, .warm):
            return [
                fly(p.parachuteAdams, size: "#14–16", tactic: "Early and late dries"),
                fly(p.elkHairCaddis, size: "#14–18", tactic: "Evening caddis"),
                fly(p.foamHopper, size: "#10–12", tactic: "Terrestrial banks midday"),
            ]
        case (.clear, .shallow, .slow, .prime), (.clear, .shallow, .still, .prime):
            return [
                fly(p.parachuteAdams, size: "#14–18", tactic: "All-day dry in soft water"),
                fly(p.bwoSparkleDun, size: "#18–22", tactic: "Overcast BWO afternoons"),
                fly(p.elkHairCaddis, size: "#14–16", tactic: "Dusk skitter"),
            ]
        case (.clear, .shallow, .slow, _), (.clear, .shallow, .still, _):
            return [
                fly(p.bwoSparkleDun, size: "#18–22", tactic: "Small olive dries"),
                fly(p.biotMidge, size: "#20–24", tactic: "Film midges"),
                fly(p.midgeEmerger, size: "#20–22", tactic: "Emerger in tailouts"),
            ]
        case (.stained, .midDepth, _, .prime), (.stained, .midDepth, _, .warm):
            return [
                fly(p.princeNymph, size: "#12–16", tactic: "Beadhead through ledges"),
                fly(p.haresEar, size: "#14–16", tactic: "Natural nymph profile"),
                fly(p.softHackle, size: "#14–16", tactic: "Swing through seams"),
            ]
        case (.stained, _, .moderate, _), (_, .midDepth, .moderate, _):
            return [
                fly(p.princeNymph, size: "#10–14", tactic: "Weight for moderate flow"),
                fly(p.rubberLegsStone, size: "#8–12", tactic: "Pat's along structure"),
                fly(p.coneheadBugger, size: "#6–8", tactic: "Deep swing"),
            ]
        case (_, .deep, .fast, _), (_, .deep, .moderate, _):
            return [
                fly(p.coneheadBugger, size: "#6–8", tactic: "Deep swing on tip"),
                fly(p.rubberLegsStone, size: "#6–10", tactic: "Heavy nymph dead-drift"),
                fly(p.woollyBugger, size: "#6–8", tactic: "Strip through tailouts"),
            ]
        default:
            return [
                fly(p.pheasantTail, size: "#14–18", tactic: "Versatile nymph"),
                fly(p.haresEar, size: "#14–16", tactic: "Natural mayfly nymph"),
                fly(p.softHackle, size: "#14–16", tactic: "Active swing"),
            ]
        }
    }

    // MARK: - Steelhead

    private static func steelheadFlies(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity
    ) -> [RecommendedFly] {
        let p = FlyPatternPhotoLibrary.self

        if turbidity == .muddy {
            return [
                fly(p.largeStreamer, size: "#2–4", tactic: "Black/purple intruder in high water"),
                fly(p.coneheadBugger, size: "#4–6", tactic: "Heavy profile in soft holding water"),
                fly(p.rubberLegsStone, size: "#6–8", tactic: "Dead-drift eggs/stones in seams"),
            ]
        }

        if temp == .frigid || temp == .cold {
            if current == .still || current == .slow {
                return [
                    fly(p.pinkRoeEgg, size: "#10–14", tactic: "Peach/chartreuse egg in pool heart"),
                    fly(p.sanJuanWorm, size: "#12–14", tactic: "Dead-drift egg or worm"),
                    fly(p.stoneflyNymph, size: "#8–12", tactic: "Small dark stone in tailouts"),
                ]
            }
            return [
                fly(p.pinkRoeEgg, size: "#10–12", tactic: "Egg pattern through softer slots"),
                fly(p.stoneflyNymph, size: "#8–10", tactic: "Beadhead stone in travel lanes"),
                fly(p.softHackle, size: "#12–14", tactic: "Sparse soft hackle swing—barely moving"),
            ]
        }

        if temp == .hot {
            return [
                fly(p.eggSuckingLeech, size: "#4–6", tactic: "Dawn swing in shaded runs only"),
                fly(p.woollyBugger, size: "#6–8", tactic: "Dark bugger in cool inflows"),
                fly(p.softHackle, size: "#12–14", tactic: "Dead-drift in deepest soft water"),
            ]
        }

        if waterType == .smallStream {
            switch (current, depth) {
            case (.still, _), (.slow, .shallow):
                return [
                    fly(p.pinkRoeEgg, size: "#12–16", tactic: "Indicator eggs through tailouts"),
                    fly(p.softHackle, size: "#12–14", tactic: "Dead-drift soft hackle"),
                    fly(p.stoneflyNymph, size: "#10–12", tactic: "Small rubber-leg stone"),
                ]
            case (.fast, _), (_, .deep):
                return [
                    fly(p.coneheadBugger, size: "#8–10", tactic: "Compact streamer in pocket water"),
                    fly(p.pinkRoeEgg, size: "#10–14", tactic: "Egg through softer slots"),
                    fly(p.softHackle, size: "#12–14", tactic: "Swing through riffle tail"),
                ]
            default:
                return [
                    fly(p.pinkRoeEgg, size: "#12–14", tactic: "Egg-first in trib flows"),
                    fly(p.jockScott, size: "#8–12", tactic: "Smaller classic swing fly"),
                    fly(p.softHackle, size: "#12–14", tactic: "Olive/brown soft hackle"),
                ]
            }
        }

        if waterType == .lakeStillwater {
            return [
                fly(p.eggSuckingLeech, size: "#6–8", tactic: "Slow leech retrieve near inlets"),
                fly(p.woollyBugger, size: "#6–8", tactic: "Count-down along drop-offs"),
                fly(p.pinkRoeEgg, size: "#10–12", tactic: "Egg pattern at creek mouths"),
            ]
        }

        // Large river / coastal — prime and warm steelhead bands
        switch (turbidity, current, depth, temp) {
        case (.stained, .fast, _, _), (.stained, .moderate, .deep, _):
            return [
                fly(p.largeStreamer, size: "#2–4", tactic: "Purple/black intruder on sink tip"),
                fly(p.eggSuckingLeech, size: "#4–6", tactic: "Egg-sucking leech swing"),
                fly(p.rubberLegsStone, size: "#6–8", tactic: "Large stone in softer seams"),
            ]
        case (.clear, .fast, _, .prime), (.clear, .moderate, .deep, .prime):
            return [
                fly(p.greenHighlander, size: "#4–6", tactic: "Classic Spey swing through travel lanes"),
                fly(p.jockScott, size: "#4–8", tactic: "Full dress or tube swing fly"),
                fly(p.eggSuckingLeech, size: "#4–6", tactic: "Pink/purple leech on sink tip"),
            ]
        case (.clear, .slow, .shallow, .prime), (.clear, .still, .shallow, .warm):
            return [
                fly(p.greenHighlander, size: "#6–8", tactic: "Broad swing across tailout lips"),
                fly(p.atlanticSalmonFly, size: "#6–10", tactic: "Traditional hair-wing swing"),
                fly(p.softHackle, size: "#12–14", tactic: "Dead-drift in soft inside seams"),
            ]
        case (.clear, .slow, _, _), (.clear, .still, _, _) where depth != .deep:
            return [
                fly(p.pinkRoeEgg, size: "#10–14", tactic: "Nuke egg dead-drifted through pools"),
                fly(p.softHackle, size: "#12–14", tactic: "Sparse hackle in film"),
                fly(p.steelheadFly, size: "#8–12", tactic: "Smaller Spey in softer water"),
            ]
        case (_, _, _, .warm):
            return [
                fly(p.eggSuckingLeech, size: "#4–6", tactic: "Bright leech on moderate sink tip"),
                fly(p.greenHighlander, size: "#4–6", tactic: "Daytime swing in overcast water"),
                fly(p.largeStreamer, size: "#2–4", tactic: "Intruder in push water"),
            ]
        default:
            if current == .fast || depth == .deep {
                return [
                    fly(p.largeStreamer, size: "#2–4", tactic: "Intruder / comet-style swing"),
                    fly(p.steelheadFly, size: "#4–6", tactic: "Durham Ranger or tube fly"),
                    fly(p.eggSuckingLeech, size: "#4–6", tactic: "Egg-sucking leech"),
                ]
            }
            return [
                fly(p.jockScott, size: "#6–10", tactic: "Swung classic on floating line"),
                fly(p.pinkRoeEgg, size: "#10–14", tactic: "Egg in tailouts after flow bump"),
                fly(p.softHackle, size: "#12–14", tactic: "Soft hackle dead-drift"),
            ]
        }
    }

    // MARK: - Bass

    private static func bassFlies(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity
    ) -> [RecommendedFly] {
        let p = FlyPatternPhotoLibrary.self

        if temp == .frigid || temp == .cold {
            return [
                fly(p.woollyBugger, size: "#6–10", tactic: "Slow along deep banks"),
                fly(p.bluegillStreamer, size: "#6–8", tactic: "Jig-strip near wood"),
                fly(p.clouserMinnow, size: "#6–8", tactic: "Deep channel edges"),
            ]
        }

        if depth == .shallow && (temp == .prime || temp == .warm || temp == .hot) {
            return [
                fly(p.foamHopper, size: "#4–8", tactic: "Poppers on weed edges"),
                fly(p.foamAnt, size: "#10–14", tactic: "Docks and lily pads"),
                fly(p.stimulator, size: "#8–12", tactic: "Damselfly or attractor dry"),
            ]
        }

        if turbidity == .muddy || current == .fast {
            return [
                fly(p.chartreuseClouser, size: "#4–2", tactic: "Chartreuse/white in stained water"),
                fly(p.woollyBugger, size: "#4–8", tactic: "Pause-strip"),
                fly(p.bluegillStreamer, size: "#4–6", tactic: "Crayfish along banks"),
            ]
        }

        if waterType == .lakeStillwater {
            return [
                fly(p.bluegillStreamer, size: "#6–8", tactic: "Weed-line ambush"),
                fly(p.woollyBugger, size: "#6–8", tactic: "Count-down retrieve"),
                fly(p.clouserMinnow, size: "#6–8", tactic: "Drop-offs and points"),
            ]
        }

        return [
            fly(p.woollyBugger, size: "#6–8", tactic: "General streamer"),
            fly(p.coneheadBugger, size: "#4–6", tactic: "Conehead on deeper structure"),
            fly(p.clouserMinnow, size: "#6–8", tactic: "Clouser along current breaks"),
        ]
    }

    // MARK: - Redfish

    private static func redfishFlies(
        temp: WaterTemp,
        turbidity: Turbidity,
        waterType: WaterType
    ) -> [RecommendedFly] {
        let p = FlyPatternPhotoLibrary.self

        if temp == .frigid || temp == .cold {
            return [
                fly(p.clouserMinnow, size: "#4–2", tactic: "Deeper channels and potholes"),
                fly(p.saltwaterDeceiver, size: "#2–1", tactic: "Shrimp in moving water"),
                fly(p.chartreuseClouser, size: "#2–1", tactic: "Stained back-country"),
            ]
        }

        if turbidity == .muddy || turbidity == .stained {
            return [
                fly(p.chartreuseClouser, size: "#2–1", tactic: "Loud strip in off-color water"),
                fly(p.clouserMinnow, size: "#2–1", tactic: "Contrast profile"),
                fly(p.saltwaterDeceiver, size: "#2–0", tactic: "Shrimp in deeper mangrove shade"),
            ]
        }

        if waterType == .coastalFlats && temp == .hot {
            return [
                fly(p.saltwaterDeceiver, size: "#4–2", tactic: "Crab on grass edges at dawn"),
                fly(p.clouserMinnow, size: "#4–2", tactic: "Shrimp on sand"),
                fly(p.chartreuseClouser, size: "#2–1", tactic: "Backup in chop"),
            ]
        }

        return [
            fly(p.saltwaterDeceiver, size: "#4–2", tactic: "Crab or shrimp on flats"),
            fly(p.clouserMinnow, size: "#4–2", tactic: "Sight-fishing profile"),
            fly(p.chartreuseClouser, size: "#2–1", tactic: "Windy or stained backup"),
        ]
    }
}
