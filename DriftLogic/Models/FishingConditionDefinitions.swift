import Foundation

// MARK: - Shared condition metadata

/// Metadata shown in pickers and woven into the rig rationale.
protocol FishingCondition: CaseIterable, Identifiable, Hashable
    where Self: RawRepresentable, Self.RawValue == String {
    var displayName: String { get }
    var definition: String { get }
    var howToIdentify: String { get }
    var rigImpact: String { get }
    var shortDescriptor: String { get }
}

extension FishingCondition {
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum ConditionCategory: String {
    case water = "Water"
    case current = "Current"
    case depth = "Depth"
    case waterTemperature = "Water Temperature"
    case clarity = "Clarity"
    case target = "Target"
    case onTheWater = "On the Water"

    var overview: String {
        switch self {
        case .water:
            return "Where you are fishing shapes rod weight, cast room, and whether you need river, lake, or salt setups."
        case .current:
            return "Flow speed controls sink rate, leader length, and whether you dead-drift, swing, or strip."
        case .depth:
            return "How deep fish are holding determines line sink, weight, and fly style."
        case .waterTemperature:
            return "Use a stream or pool thermometer in the water you are fishing—not the weather app air temperature. Fish respond to water heat; air temp alone often misleads (spring mornings, tailwaters, deep lakes)."
        case .clarity:
            return "Visibility affects how well fish see your tippet and whether you go subtle or bold."
        case .target:
            return "Species sets baseline tackle strength, typical flies, and presentation style."
        case .onTheWater:
            return "Optional: pick what you see hatching or on the surface to refine flies. Leave on Not sure if nothing obvious is active."
        }
    }
}

// MARK: - Water

extension WaterType: FishingCondition {
    var definition: String {
        switch self {
        case .smallStream:
            return "Narrow channels roughly 5–25 ft wide, often tree-lined, with limited backcast room and spooky fish."
        case .largeRiver:
            return "Broad moving water—main channels, long riffles, and deep runs where wading or boat access is common."
        case .lakeStillwater:
            return "Lakes, ponds, or reservoirs with little or no current; fish cruise structure, weed edges, and thermoclines."
        case .coastalFlats:
            return "Shallow saltwater bays and flats (often under 4 ft) with tidal movement, grass, sand, and sight-fishing."
        }
    }

    var howToIdentify: String {
        switch self {
        case .smallStream:
            return "You can cast across the stream in one or two false casts; obstructions and overhanging cover are common."
        case .largeRiver:
            return "The main flow is too wide to cast across; you fish seams, banks, or runs from wading lanes or a boat."
        case .lakeStillwater:
            return "No meaningful downstream drift—wind, chop, and retrieve speed matter more than current seams."
        case .coastalFlats:
            return "Salt air, tidal flat, mangrove or grass edges; you spot fish or poling/skiff is typical."
        }
    }

    var rigImpact: String {
        switch self {
        case .smallStream:
            return "Favors lighter floating lines (3–5 wt), shorter leaders, and delicate dries or small nymphs."
        case .largeRiver:
            return "Allows 5–6 wt floating lines; adds sink-tips when runs are deep or pushy."
        case .lakeStillwater:
            return "Uses longer fluorocarbon leaders and intermediate or sinking lines when fish are off the bottom."
        case .coastalFlats:
            return "Calls for 8–9 wt saltwater floating lines and stout fluorocarbon leaders for wind and abrasion."
        }
    }

    var shortDescriptor: String {
        switch self {
        case .smallStream: return "tight canopy, short casts"
        case .largeRiver: return "wide channels and runs"
        case .lakeStillwater: return "no river current"
        case .coastalFlats: return "shallow tidal salt"
        }
    }
}

// MARK: - Current

extension CurrentSpeed: FishingCondition {
    var definition: String {
        switch self {
        case .still:
            return "No visible flow—water looks like glass (ponds, backwaters, or wind-sheltered lake coves)."
        case .slow:
            return "Gentle movement you can easily wade against; soft seams and slow bubble lines."
        case .moderate:
            return "Steady walking-pace flow; distinct seams and riffles but still comfortable to wade with care."
        case .fast:
            return "Strong, pushy current; difficult wading, turbulent surface, and fish hugging edges or bottom."
        }
    }

    var howToIdentify: String {
        switch self {
        case .still:
            return "A floating leaf barely moves, or only drifts with wind—not downstream current."
        case .slow:
            return "You can wade upstream without leaning hard; foam lines drift lazily (roughly 0.5–1 ft/sec)."
        case .moderate:
            return "Foam moves at a brisk walk; you need deliberate foot placement (about 1–3 ft/sec)."
        case .fast:
            return "Standing is difficult in mid-channel; foam races by and pockets form behind boulders (3+ ft/sec)."
        }
    }

    var rigImpact: String {
        switch self {
        case .still:
            return "Enables long leaders, light tippet, and dry flies with minimal weight."
        case .slow:
            return "Supports dead-drift dries and nymphs; finesse tippet when water is clear."
        case .moderate:
            return "Often needs beadhead nymphs or split shot to reach depth while maintaining a natural drift."
        case .fast:
            return "Pushes shorter, stiffer leaders, heavier tippet, sink-tips, and larger or weighted flies."
        }
    }

    var shortDescriptor: String {
        switch self {
        case .still: return "no downstream flow"
        case .slow: return "soft seams, easy wading"
        case .moderate: return "walking-pace riffles"
        case .fast: return "pushy, hard to wade"
        }
    }
}

// MARK: - Depth

extension WaterDepth: FishingCondition {
    var displayName: String {
        switch self {
        case .shallow: return "Shallow"
        case .midDepth: return "Mid Depth"
        case .deep: return "Deep"
        }
    }

    var definition: String {
        switch self {
        case .shallow:
            return "Wadable water roughly ankle to waist deep, with most active fish in the top 1–3 ft of the column."
        case .midDepth:
            return "Typically 3–8 ft deep—fish hold mid-column or just off the bottom in runs and drop-offs."
        case .deep:
            return "Greater than about 8 ft, or deep slots/pools where fish sit near the bottom out of heavy surface current."
        }
    }

    var howToIdentify: String {
        switch self {
        case .shallow:
            return "You see bottom detail (rocks, grass) and fish backs or fins may break the surface."
        case .midDepth:
            return "Bottom is visible but faint, or you mark fish on sonar/indicator set at several feet."
        case .deep:
            return "Bottom is not visible from shore/boat; indicator or sink-tip is required to reach fish consistently."
        }
    }

    var rigImpact: String {
        switch self {
        case .shallow:
            return "Prioritizes floating lines, dries, and fine tippet with minimal weight."
        case .midDepth:
            return "Favors beadhead nymphs, soft hackles, and moderate leader length with optional split shot."
        case .deep:
            return "Requires sink-tips or sinking lines, heavier flies, and stronger tippet to fight current and depth."
        }
    }

    var shortDescriptor: String {
        switch self {
        case .shallow: return "top 1–3 ft of the water column"
        case .midDepth: return "roughly 3–8 ft deep"
        case .deep: return "8 ft+ or bottom-hugging fish"
        }
    }
}

// MARK: - Temperature

extension WaterTemp: FishingCondition {
    var displayName: String {
        switch self {
        case .frigid: return "Frigid water (under 42°F)"
        case .cold: return "Cold water (42–50°F)"
        case .prime: return "Prime water (50–64°F)"
        case .warm: return "Warm water (64–75°F)"
        case .hot: return "Hot water (above 75°F)"
        }
    }

    var definition: String {
        let base: String
        switch self {
        case .frigid:
            base = "Wintry or spring runoff cold in the water—minimal insect activity, fish hold in slow, deep water, and takes are subtle."
        case .cold:
            base = "Early season or cold tailwater—fish feed but conserve energy; small subsurface patterns outperform large dries."
        case .prime:
            base = "The broad “sweet spot” for most cold-water species—strong metabolism, reliable hatches, and normal fly sizes (#12–18)."
        case .warm:
            base = "Summer warmth—bass and redfish excel; trout and steelhead may still feed but demand faster recovery and shade."
        case .hot:
            base = "Mid-summer heat—focus on dawn/dusk, deep shade, or species that tolerate heat (bass, redfish); trout stress rises sharply above ~68°F."
        }
        return "\(base) Range: \(fahrenheitRange)."
    }

    var howToIdentify: String {
        switch self {
        case .frigid:
            return "Submerged thermometer below 42°F in the run you plan to fish—not the air reading on your phone."
        case .cold:
            return "42–50°F on a stream thermometer; breath visible, trout in soft water, bass still slow on flats."
        case .prime:
            return "50–64°F—active rises, comfortable wading without heat stress, BWO/caddis/midge activity on trout rivers."
        case .warm:
            return "64–75°F—hopper and damselfly season on lakes; redfish aggressive on flats; trout fishing best early/late."
        case .hot:
            return "Water above 75°F in the shallows you are fishing; midday trout slow even if morning air felt cool."
        }
    }

    /// Reinforcement on the detail screen after a band is selected.
    static let waterVersusAirNote = """
    Remember: outside air temperature is not the same as water temperature. If your weather app says 72°F, the river might still be 56°F—or a shallow flat might be 78°F. This rig is based on the water band you selected above.
    """

    var rigImpact: String {
        switch self {
        case .frigid:
            return "Micro-nymphs (#20–24), eggs, and slow dead-drifts; longest leaders and lightest tippet you can turn over."
        case .cold:
            return "Small nymphs (#16–22), eggs, and streamers fished slow and deep; shorten drifts through soft seams."
        case .prime:
            return "Full toolbox—dry-dropper, emergers, standard nymphs (#14–18), and moderate tippet (5X–6X) for trout."
        case .warm:
            return "Terrestrials, poppers, and bass/streamer patterns; for trout use early-morning dries then deeper nymphs."
        case .hot:
            return "Dawn/dusk presentations; bass poppers at first light, redfish shrimp/crab, trout only in coldest inflows if at all."
        }
    }

    var shortDescriptor: String {
        fahrenheitRange
    }
}

// MARK: - Clarity

extension Turbidity: FishingCondition {
    var definition: String {
        switch self {
        case .clear:
            return "You can see the bottom in 4+ ft of water; fish are wary and tippet is highly visible."
        case .stained:
            return "Tea-colored or slightly off water—bottom visible only 1–4 ft down; moderate fish visibility."
        case .muddy:
            return "Chocolate milk after rain or runoff—bottom not visible; fish rely on silhouette and vibration."
        }
    }

    var howToIdentify: String {
        switch self {
        case .clear:
            return "You spot fish or rocks sharply; polarized glasses reveal detail at distance."
        case .stained:
            return "Submerged logs are fuzzy; a white lure disappears within a few feet underwater."
        case .muddy:
            return "A white fly vanishes within a foot; spinner water or blowout conditions after storms."
        }
    }

    var rigImpact: String {
        switch self {
        case .clear:
            return "Demands long leaders and 5X–7X tippet with natural-colored flies."
        case .stained:
            return "Allows 3X–4X tippet and flies with flash or contrast without going oversized."
        case .muddy:
            return "Uses short stiff leaders, 2X–3X tippet, dark or bright bulky flies, and often sinking lines."
        }
    }

    var shortDescriptor: String {
        switch self {
        case .clear: return "4+ ft visibility"
        case .stained: return "1–4 ft visibility"
        case .muddy: return "under 1 ft visibility"
        }
    }
}

// MARK: - Target

extension TargetSpecies: FishingCondition {
    var definition: String {
        switch self {
        case .trout:
            return "Rainbow, brown, brook, or cutthroat in rivers and lakes—selective feeders in clear water."
        case .bassPanfish:
            return "Largemouth/smallmouth bass and bluegill—ambush structure, tolerate warmer water, strong pulls."
        case .steelhead:
            return "Migratory rainbow in rivers—hold in tailouts and runs; swung flies and nymphs in cool flows."
        case .redfish:
            return "Red drum on coastal flats and marshes—cruise shallow water, eat crabs and shrimp patterns."
        }
    }

    var howToIdentify: String {
        switch self {
        case .trout:
            return "Regulations, hatches, or sightings of trout rises in riffles and pools."
        case .bassPanfish:
            return "Lily pads, docks, brush piles, and topwater splashes in warm lakes or sluggish river backwaters."
        case .steelhead:
            return "Steelhead rivers in fall–spring; fish staged in tailouts after rain or flow bumps."
        case .redfish:
            return "Tailing pushes on flats, copper flashes in skinny water, or marsh creek systems."
        }
    }

    var rigImpact: String {
        switch self {
        case .trout:
            return "Baseline 4–6 wt systems with condition-driven leader length and fly size."
        case .bassPanfish:
            return "5–7 wt floating lines, stouter tippet, poppers and streamers on structure."
        case .steelhead:
            return "7–8 wt Spey/switch setups, 0X–2X tippet, swung flies and intruders."
        case .redfish:
            return "8–9 wt saltwater lines, 16–20 lb shock tippet, crab and minnow patterns."
        }
    }

    var shortDescriptor: String {
        switch self {
        case .trout: return "selective river/lake trout"
        case .bassPanfish: return "warmwater bass and panfish"
        case .steelhead: return "migratory steelhead"
        case .redfish: return "shallow-water redfish"
        }
    }
}

