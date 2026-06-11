import Foundation

struct RigRationaleBullet: Identifiable, Equatable {
    let title: String
    let detail: String

    var id: String { title }
}

/// Readable summary of why the rig matches conditions—for the selected target species only.
struct RigRationale: Equatable {
    let headline: String
    let bullets: [RigRationaleBullet]
}

enum RigRationaleBuilder {

    static func build(
        waterType: WaterType,
        current: CurrentSpeed,
        depth: WaterDepth,
        temp: WaterTemp,
        turbidity: Turbidity,
        species: TargetSpecies,
        hatch: ActiveHatch
    ) -> RigRationale {
        var headline = """
        Built for \(species.displayName) in \(waterType.displayName.lowercased()), \
        \(depth.displayName.lowercased()) / \(current.displayName.lowercased()) current, \
        \(temp.fahrenheitRange) water, \(turbidity.displayName.lowercased()) clarity.
        """
        if hatch.isSelected, hatch.influencesRig(species: species, turbidity: turbidity) {
            headline += " Active on the water: \(hatch.displayName)."
        }

        var bullets: [RigRationaleBullet] = [
            RigRationaleBullet(
                title: "Where",
                detail: species.habitatNote(waterType: waterType)
            ),
            RigRationaleBullet(
                title: "Depth & flow",
                detail: depthAndFlowNote(depth: depth, current: current, species: species)
            ),
            RigRationaleBullet(
                title: "Water temp",
                detail: temp.rationaleNote(for: species)
            ),
            RigRationaleBullet(
                title: "Clarity",
                detail: species.clarityNote(turbidity: turbidity)
            ),
        ]

        if hatch.isSelected {
            bullets.append(
                RigRationaleBullet(
                    title: "On the water",
                    detail: hatch.rationaleNote(species: species)
                )
            )
        }

        return RigRationale(headline: headline, bullets: bullets)
    }

    private static func depthAndFlowNote(
        depth: WaterDepth,
        current: CurrentSpeed,
        species: TargetSpecies
    ) -> String {
        switch species {
        case .trout:
            switch (depth, current) {
            case (.shallow, .still), (.shallow, .slow):
                return "Shallow, soft water—trout rise to dries; use long leaders and light tippet."
            case (.deep, .fast), (.deep, .moderate):
                return "Deep or pushy water—get nymphs and streamers down with weight or sink-tip."
            default:
                return "\(depth.displayName) trout in \(current.displayName.lowercased()) current—balance weight so the fly drifts naturally."
            }
        case .steelhead:
            switch current {
            case .fast, .moderate:
                return "Moving water—swing or drift through travel lanes and riffle heads."
            case .slow, .still:
                return "Softer water—dead-drift eggs and nymphs through pool hearts and tailouts."
            default:
                return "\(depth.displayName) holding water in \(current.displayName.lowercased()) current."
            }
        case .bassPanfish:
            switch (depth, current) {
            case (.shallow, _):
                return "Shallow cover—bass ambush edges; poppers and bugs when water temp supports topwater."
            case (.deep, .fast):
                return "Deep or moving water—slow streamers and weighted flies along structure."
            default:
                return "\(depth.displayName) bass on \(current.displayName.lowercased()) current—work banks and wood."
            }
        case .redfish:
            switch depth {
            case .shallow:
                return "Skinny water—lead cruising fish and match shrimp or crab to the bottom."
            case .deep:
                return "Deeper edges and channels—intermediate lines and slower strips when fish leave the flat."
            default:
                return "Mid-depth redfish—intermediate retrieve with shrimp or minnow patterns."
            }
        }
    }
}

// MARK: - Species-specific copy

extension TargetSpecies {

    func habitatNote(waterType: WaterType) -> String {
        switch self {
        case .trout:
            switch waterType {
            case .smallStream:
                return "Small-stream trout need short casts, light line, and stealth in tight cover."
            case .largeRiver:
                return "River trout use seams and runs—adjust weight and leader for depth and flow."
            case .lakeStillwater:
                return "Lake trout cruise structure and thermoclines—use longer leaders and stillwater retrieves."
            case .coastalFlats:
                return "Unusual for trout—if present, they are in cool inflows; fish tiny flies in moving water."
            }
        case .steelhead:
            switch waterType {
            case .smallStream, .largeRiver:
                return "Steelhead rivers—focus on tailouts, riffles, and soft water below heavy flow."
            case .lakeStillwater:
                return "Lake-run fish—follow tributary mouths and cool inflows."
            case .coastalFlats:
                return "Not typical steelhead habitat—use river rules if fishing an estuary."
            }
        case .bassPanfish:
            switch waterType {
            case .lakeStillwater:
                return "Lake bass relate to weed lines, docks, and points—cover water with streamers and poppers."
            case .smallStream, .largeRiver:
                return "River bass hold on wood, undercut banks, and slack water off current."
            case .coastalFlats:
                return "Backwater bass—fish mangrove edges and marsh creeks with baitfish patterns."
            }
        case .redfish:
            switch waterType {
            case .coastalFlats:
                return "Flats redfish tail and cruise skinny water—sight-cast shrimp and crab ahead of fish."
            case .lakeStillwater, .largeRiver:
                return "Estuary redfish—work channel edges and grass lines with shrimp and minnow flies."
            case .smallStream:
                return "Tight marsh creeks—short accurate casts with crab and spoon patterns."
            }
        }
    }

    func clarityNote(turbidity: Turbidity) -> String {
        switch self {
        case .trout:
            switch turbidity {
            case .clear:
                return "Clear water—long leaders and 5X–7X tippet; match hatches closely."
            case .stained:
                return "Stained water—slightly larger nymphs and streamers with flash or contrast."
            case .muddy:
                return "Muddy water—short heavy rigs; dark or bright streamers fished tight to banks."
            }
        case .steelhead:
            switch turbidity {
            case .clear:
                return "Clear water—longer leaders and more natural swung or dead-drifted flies."
            case .stained:
                return "Stained water—larger profiles and visible egg or stonefly patterns."
            case .muddy:
                return "High water—big dark intruders and short stiff leaders in soft holding water."
            }
        case .bassPanfish:
            switch turbidity {
            case .clear:
                return "Clear water—fluorocarbon and natural baitfish or popper colors."
            case .stained, .muddy:
                return "Off-color water—chartreuse, white, or black silhouettes and vibration."
            }
        case .redfish:
            switch turbidity {
            case .clear:
                return "Clear flats—natural crab and shrimp tones matched to sand or grass."
            case .stained:
                return "Stained water—flashy Clousers and contrasty shrimp patterns."
            case .muddy:
                return "Dirty water—chartreuse/white Clousers with loud strips near deeper edges."
            }
        }
    }
}
