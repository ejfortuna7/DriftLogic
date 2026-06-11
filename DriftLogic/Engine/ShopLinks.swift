import Foundation

/// Mechanical port of the shop-link builders from the verified web engine
/// (driftlogic-engine-reference.js): `buyURL` (Amazon), `buyURL2` (Bass Pro),
/// and `buyURL3` (FishUSA). The web UI render uses `buyURL` (Amazon) and
/// `buyURL3` (FishUSA); `buyURL2` (Bass Pro) is defined in the JS but not
/// rendered. All three are ported here.
enum ShopLinks {

    // MARK: - Pick-name cleanup (shared by all three JS builders)
    //
    // JS: n.replace(/&[a-z]+;/g,' ')
    //      .replace(/#.*/,'')
    //      .replace(/\(.*?\)/g,'')
    //      .split(/\s[-–—]\s/)[0]
    //      .replace(/[\/]/g,' ')
    //      .replace(/\s+/g,' ')
    //      .trim()
    //
    // The Swift pick names are already HTML-entity-decoded, so the first step
    // (entities → space) is replicated by replacing the decoded characters
    // (– — & ° · ") with a space.

    private static func cleanedQuery(_ name: String) -> String {
        var b = name
        // JS step 1: /&[a-z]+;/g → ' '  (applied to the decoded characters)
        b = b.replacingOccurrences(of: "[–—&°·\"]", with: " ", options: .regularExpression)
        // JS step 2: /#.*/ → ''  (drop everything from the first '#', e.g. size info)
        b = b.replacingOccurrences(of: "#.*", with: "", options: .regularExpression)
        // JS step 3: /\(.*?\)/g → ''  (drop parenthesised qualifiers)
        b = b.replacingOccurrences(of: "\\(.*?\\)", with: "", options: .regularExpression)
        // JS step 4: split(/\s[-–—]\s/)[0]  (keep text before a spaced dash)
        if let r = b.range(of: "\\s[-–—]\\s", options: .regularExpression) {
            b = String(b[..<r.lowerBound])
        }
        // JS step 5: /[\/]/g → ' '
        b = b.replacingOccurrences(of: "/", with: " ")
        // JS step 6: /\s+/g → ' '
        b = b.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        // JS step 7: trim()
        return b.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - encodeURIComponent
    // JS encodeURIComponent leaves A–Z a–z 0–9 - _ . ! ~ * ' ( ) unescaped.

    private static let uriComponentAllowed = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*'()"
    )

    private static func encodeURIComponent(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: uriComponentAllowed) ?? s
    }

    // MARK: - buyURL (Amazon, used by the web UI render)

    static func amazonURL(for pickName: String) -> URL {
        // Curated, product-accurate search term when we have one; otherwise the
        // legacy web-engine heuristic (name cleanup + " fishing").
        amazonSearchURL(for: amazonSearchOverrides[pickName] ?? (cleanedQuery(pickName) + " fishing"))
    }

    /// Amazon search URL for an arbitrary query, with the Associates tag.
    static func amazonSearchURL(for query: String) -> URL {
        URL(string: "https://www.amazon.com/s?k=" + encodeURIComponent(query) + "&tag=rockyriver-20")!
    }

    // MARK: - Curated Amazon search terms
    //
    // The pick names are rig descriptions ("Tube under a float - green pumpkin"),
    // not product names — naive search returns towable boat tubes, WD-40 oil, etc.
    // Every pick the engine can produce has a hand-written, product-accurate
    // Amazon query here. GoldenMasterTests asserts 100% coverage.
    // Live-bait picks (minnows, shad, livers) map to the closest purchasable
    // product (preserved bait, rig hardware, or the float/jig component).

    static let amazonSearchOverrides: [String: String] = [
        // ---- Fly · steelhead ----
        "BWO Parachute #18–20": "bwo parachute dry fly size 18",
        "BWO Sparkle Dun #18–20": "bwo sparkle dun fly",
        "Black Beauty #20–22": "black beauty midge fly size 20",
        "Black/Blue Woolly Bugger #4": "woolly bugger black size 4 fly",
        "Caddis Pupa #16": "caddis pupa fly size 16",
        "Copper John #12–14": "copper john nymph fly",
        "Crystal Meth Egg #10–12": "estaz egg fly steelhead chartreuse",
        "Dark Intruder #2–4": "intruder fly steelhead black",
        "Egg-Sucking Leech": "egg sucking leech fly",
        "Egg-Sucking Leech (black/purple)": "egg sucking leech fly black",
        "Elk Hair Caddis #14–16": "elk hair caddis flies",
        "Estaz Egg (chartreuse) #8": "estaz egg fly chartreuse",
        "Estaz Egg (chartreuse/orange) #8": "estaz egg fly chartreuse orange",
        "Glo Bug Egg #10–12": "glo bug egg fly steelhead",
        "Green Caddis Larva #14": "caddis larva fly green",
        "Griffiths Gnat #18": "griffiths gnat fly",
        "Hares Ear Nymph #12": "hares ear nymph flies",
        "Hares Ear Nymph #12–14": "hares ear nymph flies",
        "Marabou Spey Fly": "marabou spey fly steelhead",
        "Midge Emerger #20": "midge emerger flies size 20",
        "Pheasant Tail Nymph #10–14": "pheasant tail nymph flies",
        "Pheasant Tail Nymph #16–18": "pheasant tail nymph flies size 16",
        "Pink Worm": "san juan worm fly pink steelhead",
        "Prince Nymph #12": "prince nymph flies size 12",
        "RS2 #22": "rs2 fly size 22",
        "RS2 Emerger #20": "rs2 emerger fly",
        "Rubber-Leg Stone #6–8": "rubber legs stonefly nymph",
        "Soft Hackle #14": "soft hackle wet fly",
        "Soft-bead Egg Fly": "soft bead egg steelhead peg",
        "Stonefly Nymph #8–10": "stonefly nymph flies",
        "Sucker Spawn": "sucker spawn egg fly",
        "WD-40 Emerger #20": "baetis midge emerger flies size 20",
        "X-Caddis #16": "x caddis fly size 16",
        "Zebra Midge #18–20": "zebra midge flies",
        // ---- Fly · smallmouth ----
        "Black/olive bulky Bugger #2": "woolly bugger streamer black olive size 2",
        "Brown Woolly Bugger #6": "brown woolly bugger flies",
        "Chartreuse crayfish pattern #6": "chartreuse crayfish fly bass",
        "Chartreuse/white Clouser #4": "clouser minnow chartreuse white size 4",
        "Chartreuse/white Clouser Minnow #4": "clouser minnow chartreuse white size 4",
        "Clouser Minnow (olive/white) #4": "clouser minnow olive white size 4",
        "Crayfish Pattern #6": "crayfish fly smallmouth bass",
        "Deer Hair Popper #4-6": "deer hair popper fly bass",
        "Goby streamer (natural) #4": "goby fly smallmouth streamer",
        "Gold Clouser #4": "clouser minnow gold size 4",
        "Marabou leech (natural)": "marabou leech fly",
        "Murdich Minnow #4": "murdich minnow fly",
        "Olive Goby / Sculpin Streamer #4-6": "sculpin streamer fly olive",
        "Olive Goby Streamer #4-6": "goby fly streamer olive",
        "Olive sculpin streamer #4": "sculpin streamer fly olive size 4",
        "Small Clouser (natural) #6": "clouser minnow size 6",
        "Sneaky Pete Popper #6": "sneaky pete popper fly",
        "White Murdich Minnow #4": "murdich minnow fly white",
        "Woolly Bugger (olive/black) #6": "woolly bugger olive black size 6",
        // ---- Fly · walleye ----
        "Chartreuse marabou jig-fly": "marabou jig chartreuse 1/8 oz",
        "Chartreuse/white Clouser Minnow #2-4": "clouser minnow chartreuse white size 2",
        "Gold Clouser Minnow #2": "clouser minnow gold size 2",
        "Marabou jig-fly (brown)": "marabou jig brown 1/8 oz",
        "Marabou jig-fly (natural)": "marabou jig natural 1/8 oz",
        "Olive/white Clouser Minnow #2-4": "clouser minnow olive white size 2",
        "Orange-bead leech pattern": "bead head leech fly orange",
        "Sculpin streamer #4": "sculpin streamer fly size 4",
        "Weighted black Woolly Bugger #4": "woolly bugger black bead head size 4",
        "White Zonker / bunny streamer #2": "zonker streamer fly white",
        "White bunny streamer #2": "bunny streamer fly white",
        // ---- Fly · catfish ----
        "Black/purple leech": "leech fly black purple",
        "Black/red bulky bunny leech": "bunny leech fly black",
        "Flesh / worm fly": "san juan worm fly large",
        "Heavy Clouser Minnow #1/0": "clouser minnow 1/0 weighted",
        "Heavy chartreuse Clouser #1/0": "clouser minnow chartreuse 1/0",
        "Heavy olive sculpin #2": "weighted sculpin streamer fly",
        "Olive sculpin streamer #2": "sculpin streamer fly olive size 2",
        "White/olive bunny leech #2": "bunny leech fly white olive",
        "Large dark articulated streamer": "articulated streamer fly black",
        "Large white articulated streamer": "articulated streamer fly white",
        "Large white/chartreuse articulated streamer": "articulated streamer fly chartreuse",
        "Pink flesh / worm fly": "pink worm fly steelhead",
        "Weighted black bunny leech": "bunny leech fly black weighted",
        "White game-changer streamer": "game changer fly white",
        // ---- Spin · steelhead ----
        "10–12 mm orange bead under a float": "trout beads 10mm orange steelhead",
        "14 mm bright bead drifted on bottom": "trout beads 14mm chartreuse",
        "Bright jig (chartreuse/pink) under a float": "steelhead jig chartreuse pink 1/8",
        "Chartreuse-blade Vibrax Spinner": "blue fox vibrax spinner chartreuse",
        "Chartreuse/Orange Spoon": "little cleo spoon chartreuse orange",
        "Colorado-blade Spinner (chartreuse)": "colorado blade spinner chartreuse",
        "Cured spawn sac (bright mesh)": "spawn sac netting trout egg bait",
        "Cured spawn sac": "spawn sacs trout egg bait",
        "Float + 1/16 oz jig and maggots": "steelhead float jig 1/16 oz",
        "Gold/Orange Spoon (Little Cleo)": "little cleo spoon gold orange",
        "Kwikfish / Mag Lip plug": "mag lip plug steelhead",
        "Natural soft bead (8–10 mm) under a float": "soft beads 8mm trout peach",
        "Pink/Orange jig under a float": "steelhead jig pink orange 1/8 oz",
        "Silver Inline Spinner (Vibrax / Mepps #3)": "blue fox vibrax silver size 3",
        "Silver/Gold Spoon (Little Cleo, 1/4–3/8 oz)": "little cleo spoon 1/4 oz",
        // ---- Spin · smallmouth ----
        "3 in Tube — dark/black": "tube bait black 3 inch bass",
        "3 in Tube — green pumpkin / goby (1/8–1/4 oz)": "tube bait green pumpkin 2.75 inch",
        "3 in Tube — natural": "tube bait natural smoke 3 inch",
        "Blade bait (silver)": "blade bait silver bass",
        "Chartreuse Spinnerbait": "spinnerbait chartreuse bass",
        "Chatterbait (chartreuse/white)": "chatterbait chartreuse white",
        "Colorado-blade Spinner (gold)": "inline spinner gold colorado",
        "Crawfish Square-bill Crankbait": "squarebill crankbait crawfish",
        "Drop-shot worm": "drop shot worms finesse bass",
        "Hair jig (brown/olive) 1/8 oz": "hair jig 1/8 oz smallmouth",
        "Inline Spinner (Mepps #2–3, gold)": "mepps aglia gold size 3",
        "Jerkbait — shad / minnow": "jerkbait shad bass",
        "Ned Rig — green pumpkin": "ned rig kit green pumpkin",
        "Rebel Craw (rocky sections)": "rebel crawfish crankbait",
        // ---- Spin · walleye ----
        "Chartreuse / firetiger stickbait": "rapala husky jerk firetiger",
        "Firetiger crankbait": "crankbait firetiger walleye",
        "Gold blade bait": "blade bait gold walleye",
        "Hair jig + minnow (1/8 oz)": "hair jig 1/8 oz walleye",
        "Jig + chartreuse twister": "twister tail grub chartreuse jig heads",
        "Jig + minnow or twister (1/8–1/4 oz)": "walleye jig heads 1/8 1/4 oz",
        "Jig + nightcrawler (1/4 oz)": "walleye jig heads 1/4 oz",
        "Shallow stickbait (Husky Jerk / Rapala P10)": "rapala husky jerk 10",
        "Silver blade bait": "blade bait silver walleye",
        "Suspending jerkbait (natural shad)": "suspending jerkbait shad",
        // ---- Spin · catfish ----
        "Chicken liver": "chicken liver catfish bait",
        "Cut bait — shad or bluegill": "preserved shad catfish cut bait",
        "Live or dead shad": "catfish bait shad preserved",
        "Nightcrawler gob": "catfish rig hooks nightcrawler bait holder",
        "Prepared dip bait (tube)": "catfish dip bait tubes",
        "Shrimp on a circle hook": "circle hooks catfish size 5/0",
        "Stink / punch bait": "catfish punch bait",
        // ---- Pin · steelhead ----
        "1/16 oz jig + maggots (black/white)": "steelhead jig 1/16 oz black white",
        "1/8 oz pink jig + maggots": "steelhead jig pink 1/8 oz",
        "10–12 mm bead (orange/pink)": "trout beads 10mm pink orange",
        "14–19 mm bead (bright orange/chartreuse)": "steelhead beads 16mm chartreuse",
        "8 mm soft bead (natural / peach)": "soft beads 8mm trout peach",
        "8 mm soft bead (peach/natural)": "soft beads 8mm trout peach",
        "Chartreuse jig under the float": "steelhead jig chartreuse marabou",
        "Estaz egg fly (chartreuse)": "estaz egg fly chartreuse",
        "Natural spawn sac (light mesh)": "spawn sac mesh trout eggs",
        "Pheasant Tail nymph under the float": "pheasant tail nymph flies",
        "Pink worm under the float": "pink steelhead worm soft plastic",
        "Stonefly nymph under the float": "stonefly nymph flies",
        // ---- Pin · smallmouth ----
        "1/16-1/8 oz hair jig (brown/olive) under a float": "hair jig 1/16 oz brown",
        "1/8 oz jig + minnow under a float": "jig heads 1/8 oz fishing",
        "Black/blue tube under a float": "tube bait black blue bass",
        "Chartreuse/orange jig + minnow under a float": "jig heads chartreuse 1/8 oz",
        "Chartreuse/white jig + minnow under a float": "jig heads chartreuse white 1/8 oz",
        "Downsized tube - green pumpkin under a float": "ned tube green pumpkin 2.5 inch",
        "Gold-blade hair jig (orange) under a float": "underspin hair jig gold blade",
        "Hair jig (brown) under a float": "marabou hair jig brown",
        "Live minnow or crayfish under a float": "slip float rig kit fishing",
        "Live minnow under a float": "slip bobber rig kit",
        "Micro jig + waxworm under a float": "micro jigs 1/32 oz panfish",
        "Orange bead / hair jig under a float": "trout beads orange 10mm",
        "Soft bead (natural / peach) under a float": "soft beads trout peach 10mm",
        "Soft bead (natural) under a float": "soft beads trout natural 10mm",
        "Soft bead (orange) under a float": "soft beads trout orange 10mm",
        "Tube - black/blue or junebug under a float": "tube bait junebug bass",
        "Tube under a float - green pumpkin / goby": "tube bait green pumpkin 2.75 inch",
        "White marabou jig under a float": "marabou jig white 1/8 oz",
        // ---- Pin · walleye ----
        "1/8 oz jig + minnow under a float (slow)": "jig heads 1/8 oz walleye",
        "Blade bait (silver) - vertical": "blade bait silver 1/2 oz",
        "Chartreuse jig + minnow under a float": "walleye jig chartreuse 1/8 oz",
        "Float + jig and nightcrawler": "slip bobber rig walleye jig",
        "Float + nightcrawler": "slip bobber rig kit nightcrawler hooks",
        "Glow / white swim jig under a float": "glow swim jig walleye",
        "Gold-blade hair jig under a float": "underspin hair jig gold blade",
        "Hair jig (brown/olive) under a float": "hair jig walleye brown",
        "Jig + minnow under a float": "jig heads walleye 1/8 oz",
        "Orange/gold bead under a float": "trout beads orange gold 12mm",
        "White/chartreuse swim jig under a float": "swim jig white chartreuse",
        // ---- Pin · catfish ----
        "Chicken liver under a float": "chicken liver catfish bait",
        "Cured shrimp under a float": "cured shrimp catfish bait",
        "Cut bait (shad) under a float - deep and slow": "preserved shad catfish cut bait",
        "Cut bait (shad/bluegill) under a float": "preserved shad catfish cut bait",
        "Live or fresh shad under a float": "catfish bait shad preserved",
        "Live shad under a float": "catfish bait shad preserved",
        "Nightcrawler gob under a float": "catfish rig hooks nightcrawler bait holder",
        "Shrimp on a circle hook under a float": "circle hooks catfish size 5/0",
        "Stink / punch bait under a float": "catfish punch bait",
    ]

    // MARK: - buyURL2 (Bass Pro; defined in the JS but not used by the render)

    static func bassProURL(for pickName: String) -> URL {
        let b = cleanedQuery(pickName)
        return URL(string: "https://www.basspro.com/SearchDisplay#q=" + encodeURIComponent(b))!
    }

    // MARK: - buyURL3 (FishUSA, used by the web UI render)

    static func fishUSAURL(for pickName: String) -> URL {
        let b = cleanedQuery(pickName)
        return URL(string: "https://www.fishusa.com/search.php?search_query=" + encodeURIComponent(b))!
    }
}
