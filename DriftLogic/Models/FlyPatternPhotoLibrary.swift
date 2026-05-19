import Foundation

/// Real fly-pattern photo loaded from Wikimedia Commons (network required).
struct FlyPatternPhoto: Identifiable, Equatable {
    let name: String
    /// Exact Commons filename, e.g. `Parachute Adams Dry Fly.jpg`
    let commonsFilename: String
    let credit: String
    let license: String

    var id: String { commonsFilename }

    var imageURL: URL {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/")
        let path = commonsFilename.replacingOccurrences(of: " ", with: "_")
            .addingPercentEncoding(withAllowedCharacters: allowed) ?? commonsFilename
        return URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(path)?width=800")!
    }

    var sourcePageURL: URL {
        let encoded = commonsFilename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? commonsFilename
        return URL(string: "https://commons.wikimedia.org/wiki/File:\(encoded)")!
    }
}

enum FlyPatternPhotoLibrary {

    // MARK: - Catalog (Wikimedia Commons)

    static let parachuteAdams = FlyPatternPhoto(
        name: "Parachute Adams",
        commonsFilename: "Parachute Adams Dry Fly.jpg",
        credit: "Freyfisher / Flickr",
        license: "CC BY-SA 2.0"
    )
    static let elkHairCaddis = FlyPatternPhoto(
        name: "Elk Hair Caddis",
        commonsFilename: "Elk Hair Caddis.JPG",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let bwoSparkleDun = FlyPatternPhoto(
        name: "Blue-Winged Olive",
        commonsFilename: "BWO Olive Sparkle Dun.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let biotMidge = FlyPatternPhoto(
        name: "Midge",
        commonsFilename: "Biot Para-Midge.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let midgeEmerger = FlyPatternPhoto(
        name: "Midge Emerger",
        commonsFilename: "Midge Emerger Flies.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let pheasantTail = FlyPatternPhoto(
        name: "Pheasant Tail Nymph",
        commonsFilename: "American Pheasant Tail Nymph 02.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let princeNymph = FlyPatternPhoto(
        name: "Beadhead Prince",
        commonsFilename: "Bead Head Prince Nymph.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let haresEar = FlyPatternPhoto(
        name: "Gold Ribbed Hare's Ear",
        commonsFilename: "Gold ribbed hairs ear trout fly.JPG",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let softHackle = FlyPatternPhoto(
        name: "Soft Hackle",
        commonsFilename: "Olive quill soft hackle nymph.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let rubberLegsStone = FlyPatternPhoto(
        name: "Rubber-Leg Stonefly",
        commonsFilename: "Rubber Legs.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let stoneflyNymph = FlyPatternPhoto(
        name: "Stonefly Nymph",
        commonsFilename: "Matt Minch Black Stonefly Nymph.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let woollyBugger = FlyPatternPhoto(
        name: "Woolly Bugger",
        commonsFilename: "Black Woolly Bugger by James Stripes.jpg",
        credit: "James Stripes",
        license: "Public domain"
    )
    static let coneheadBugger = FlyPatternPhoto(
        name: "Conehead Streamer",
        commonsFilename: "OliveRubberTailConeHeadWoollyBugger.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let clouserMinnow = FlyPatternPhoto(
        name: "Clouser Minnow",
        commonsFilename: "ClouserDeepMinnow.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let chartreuseClouser = FlyPatternPhoto(
        name: "Chartreuse Clouser",
        commonsFilename: "Chartreuse and Red Clouser Deep Minnow.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let eggSuckingLeech = FlyPatternPhoto(
        name: "Egg-Sucking Leech",
        commonsFilename: "BlackEggSuckingLeech.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let sanJuanWorm = FlyPatternPhoto(
        name: "Egg / Worm Pattern",
        commonsFilename: "San Juan worm trout fly.JPG",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let steelheadFly = FlyPatternPhoto(
        name: "Steelhead / Spey Fly",
        commonsFilename: "Durham Ranger salmon fly.jpg",
        credit: "MichaelMaggs",
        license: "CC BY-SA 3.0"
    )
    static let largeStreamer = FlyPatternPhoto(
        name: "Large Streamer",
        commonsFilename: "Mr. Nasty.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let chironomid = FlyPatternPhoto(
        name: "Chironomid",
        commonsFilename: "Trout Buzzers Flies.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let foamHopper = FlyPatternPhoto(
        name: "Hopper / Terrestrial",
        commonsFilename: "Foam Hopper.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let foamAnt = FlyPatternPhoto(
        name: "Foam Ant",
        commonsFilename: "Tan foam ant.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let stimulator = FlyPatternPhoto(
        name: "Stimulator",
        commonsFilename: "Stimulator dry fly.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let hairWingedCaddis = FlyPatternPhoto(
        name: "Caddis",
        commonsFilename: "Hair Winged Caddis.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let bluegillStreamer = FlyPatternPhoto(
        name: "Bass Streamer",
        commonsFilename: "EP Bluegill Streamer.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )
    static let saltwaterDeceiver = FlyPatternPhoto(
        name: "Saltwater Fly",
        commonsFilename: "Saltwater Deceivers.jpg",
        credit: "Wikimedia Commons contributor",
        license: "See Commons file page"
    )

    // MARK: - Match rig text to photos

    static func photos(forFlyRecommendation recommendation: String) -> [FlyPatternPhoto] {
        let text = recommendation.lowercased()
        var matched: [FlyPatternPhoto] = []

        func add(_ photo: FlyPatternPhoto) {
            guard !matched.contains(where: { $0.id == photo.id }) else { return }
            matched.append(photo)
        }

        let rules: [(String, FlyPatternPhoto)] = [
            ("parachute adams", parachuteAdams),
            ("elk hair caddis", elkHairCaddis),
            ("blue-winged olive", bwoSparkleDun),
            ("bwo", bwoSparkleDun),
            ("zebra midge", biotMidge),
            ("rs2", midgeEmerger),
            ("emerger", midgeEmerger),
            ("midge", biotMidge),
            ("pheasant tail", pheasantTail),
            ("hare's ear", haresEar),
            ("hare’s ear", haresEar),
            ("prince", princeNymph),
            ("rubber leg", rubberLegsStone),
            ("pat's", rubberLegsStone),
            ("stonefly", stoneflyNymph),
            ("soft hackle", softHackle),
            ("woolly bugger", woollyBugger),
            ("bugger", woollyBugger),
            ("intruder", largeStreamer),
            ("spey", steelheadFly),
            ("steelhead", steelheadFly),
            ("egg", sanJuanWorm),
            ("leech", eggSuckingLeech),
            ("clouser", clouserMinnow),
            ("chartreuse", chartreuseClouser),
            ("spoon fly", chartreuseClouser),
            ("popper", foamHopper),
            ("ant", foamAnt),
            ("terrestrial", foamHopper),
            ("hopper", foamHopper),
            ("damsel", softHackle),
            ("callibaetis", bwoSparkleDun),
            ("chironomid", chironomid),
            ("crayfish", bluegillStreamer),
            ("crab", saltwaterDeceiver),
            ("shrimp", saltwaterDeceiver),
            ("articulated streamer", largeStreamer),
            ("streamer", woollyBugger),
            ("conehead", coneheadBugger),
            ("dry-dropper", hairWingedCaddis),
            ("caddis", hairWingedCaddis),
            ("dry", parachuteAdams),
            ("nymph", pheasantTail),
            ("attractor", stimulator),
            ("leach", eggSuckingLeech),
        ]

        for (keyword, photo) in rules {
            if text.contains(keyword) {
                add(photo)
            }
        }

        if text.contains("dry-dropper") {
            add(princeNymph)
        }
        if text.contains("muddy") || text.contains("chartreuse/white") {
            add(chartreuseClouser)
        }

        if matched.isEmpty {
            add(pheasantTail)
        }

        return Array(matched.prefix(3))
    }
}
