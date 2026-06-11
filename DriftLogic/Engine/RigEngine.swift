import Foundation

/// Mechanical port of the verified web engine (driftlogic-engine-reference.js).
/// Every branch mirrors the JS exactly; HTML entities in the JS strings are
/// decoded to real Unicode here (&ndash; → "–", &mdash; → "—", &amp; → "&",
/// &deg; → "°"). Do not "improve" logic or text — golden-master tests compare
/// this output against the JS engine.
enum RigEngine {

    // MARK: - Display maps (JS: TEMP / SPN / MN)

    private static func tempLabel(_ t: WaterTemp) -> String {
        switch t {
        case .frigid: return "sub-42°F"
        case .cold: return "42–50°F"
        case .prime: return "50–64°F"
        case .warm: return "64–75°F"
        case .hot: return "75°F+"
        }
    }

    private static func speciesName(_ sp: Species) -> String {
        switch sp {
        case .steelhead: return "Steelhead"
        case .smallmouth: return "Smallmouth bass"
        case .walleye: return "Walleye"
        case .catfish: return "Channel catfish"
        }
    }

    private static func methodName(_ m: Method) -> String {
        switch m {
        case .fly: return "fly fishing"
        case .spin: return "spinning gear"
        case .pin: return "center-pin / float"
        }
    }

    // MARK: - setup(s)  (JS: function setup(s))

    static func setup(_ s: Scenario) -> [RigRow] {
        let m = s.method, sp = s.species, cl = s.clarity, t = s.temp
        let fc = (t == .frigid || t == .cold)
        if m == .fly {
            if sp == .steelhead {
                return [
                    RigRow(label: "Rod & line", value: "9 ft 7-wt weight-forward floating; an 11 ft switch rod helps for swinging"),
                    RigRow(label: "Leader", value: "9–10 ft tapered for indicator nymphing, or 4–5 ft level for swung flies"),
                    RigRow(label: "Tippet", value: cl == .clear ? (fc ? "2X–3X fluorocarbon" : "1X–2X fluorocarbon") : "0X–1X fluorocarbon")
                ]
            }
            if sp == .smallmouth {
                return [
                    RigRow(label: "Rod & line", value: "9 ft 6–7 wt weight-forward floating"),
                    RigRow(label: "Leader", value: "7.5–9 ft tapered"),
                    RigRow(label: "Tippet", value: cl == .muddy ? "0X–1X fluorocarbon" : "2X–3X fluorocarbon")
                ]
            }
            if sp == .walleye {
                return [
                    RigRow(label: "Rod & line", value: "9 ft 7–8 wt with an intermediate or sink-tip line; best at dusk and after dark"),
                    RigRow(label: "Leader", value: "7.5 ft tapered"),
                    RigRow(label: "Tippet", value: "0X–1X fluorocarbon")
                ]
            }
            return [
                RigRow(label: "Rod & line", value: "8–9 wt with a fast-sinking tip"),
                RigRow(label: "Leader", value: "5–6 ft, 12–15 lb"),
                RigRow(label: "Tippet", value: "0X (12–15 lb) — a niche approach; bait gear is far more effective for cats")
            ]
        }
        if m == .spin {
            if sp == .steelhead {
                return [
                    RigRow(label: "Rod", value: "8.5–9 ft medium / medium-light spinning, moderate-fast"),
                    RigRow(label: "Reel", value: "2500–3500 spinning with a smooth drag"),
                    RigRow(label: "Line", value: cl == .clear ? "8–10 lb mono, or 15 lb braid with an 8 lb fluorocarbon leader" : "10–12 lb mono, or 20 lb braid with a 10–12 lb fluorocarbon leader")
                ]
            }
            if sp == .smallmouth {
                return [
                    RigRow(label: "Rod", value: "6.5–7 ft medium spinning, fast action"),
                    RigRow(label: "Reel", value: "2500 spinning"),
                    RigRow(label: "Line", value: "8–10 lb fluorocarbon, or 10–15 lb braid with an 8 lb fluoro leader")
                ]
            }
            if sp == .walleye {
                return [
                    RigRow(label: "Rod", value: "6.5–7 ft medium spinning"),
                    RigRow(label: "Reel", value: "2500–3000 spinning"),
                    RigRow(label: "Line", value: "10 lb braid or mono with a 10–12 lb fluorocarbon leader")
                ]
            }
            return [
                RigRow(label: "Rod", value: "7 ft medium-heavy spinning or baitcast"),
                RigRow(label: "Reel", value: "3000–4000 with a strong drag"),
                RigRow(label: "Rig & line", value: "12–20 lb mono; slip-sinker bottom rig with a 2/0–4/0 circle hook")
            ]
        }
        if sp == .steelhead {
            return [
                RigRow(label: "Rod", value: "11–13 ft float (center-pin) rod"),
                RigRow(label: "Reel & mainline", value: "Center-pin reel; 12–15 lb monofilament mainline"),
                RigRow(label: "Leader & float", value: (cl == .clear ? "6 lb" : "8 lb") + " fluorocarbon leader; Raven FM or clear Drennan Loafer float, shotted so the bait rides just off the bottom")
            ]
        }
        if sp == .smallmouth {
            return [
                RigRow(label: "Rod", value: "11–12 ft float rod"),
                RigRow(label: "Reel & mainline", value: "Center-pin or spinning; 10–12 lb mainline"),
                RigRow(label: "Leader & float", value: "6–8 lb fluorocarbon; float a jig or minnow just off bottom through the pools")
            ]
        }
        if sp == .walleye {
            return [
                RigRow(label: "Rod", value: "11–12 ft float rod"),
                RigRow(label: "Reel & mainline", value: "Center-pin or spinning; 10–12 lb mainline"),
                RigRow(label: "Leader & float", value: "8–10 lb fluorocarbon; suspend a jig and minnow near bottom in the deeper slots")
            ]
        }
        return [
            RigRow(label: "Rod", value: "11–12 ft float rod (a niche approach for cats)"),
            RigRow(label: "Reel & mainline", value: "Center-pin or spinning; 15–20 lb mainline"),
            RigRow(label: "Leader & float", value: "12–15 lb leader; a large slip float parked over deep holes with cut bait or worm")
        ]
    }

    // MARK: - hatchPicks(h)  (JS: function hatchPicks(h))

    private static func hatchPicks(_ h: Hatch) -> [Pick]? {
        switch h {
        case .egg:
            return [
                Pick(name: "Glo Bug Egg #10–12", note: "The Rocky River staple; dead-drift through tailouts"),
                Pick(name: "Sucker Spawn", note: "Pale or orange on a drag-free drift"),
                Pick(name: "Soft-bead Egg Fly", note: "Match bead size to clarity"),
                Pick(name: "Crystal Meth Egg #10–12", note: "Bright egg cluster for cold or stained water"),
                Pick(name: "Estaz Egg (chartreuse) #8", note: "Flashy egg when fish want a target")
            ]
        case .bwo:
            return [
                Pick(name: "BWO Sparkle Dun #18–20", note: "Match the hatch on overcast afternoons"),
                Pick(name: "Pheasant Tail Nymph #16–18", note: "Drift below the dry"),
                Pick(name: "RS2 Emerger #20", note: "In the film as fish key on emergers"),
                Pick(name: "BWO Parachute #18–20", note: "Visible dry on the surface film"),
                Pick(name: "WD-40 Emerger #20", note: "Just under the surface in slow seams")
            ]
        case .caddis:
            return [
                Pick(name: "Elk Hair Caddis #14–16", note: "Skate or dead-drift over riffles"),
                Pick(name: "Soft Hackle #14", note: "Swing the pupa at dusk"),
                Pick(name: "Caddis Pupa #16", note: "Subsurface during the hatch"),
                Pick(name: "Green Caddis Larva #14", note: "Searching nymph through the riffles"),
                Pick(name: "X-Caddis #16", note: "Trailing-shuck emerger in the film")
            ]
        case .midge:
            return [
                Pick(name: "Zebra Midge #18–20", note: "Tiny nymph in slow, clear water"),
                Pick(name: "Griffiths Gnat #18", note: "Cluster on the surface in soft water"),
                Pick(name: "Midge Emerger #20", note: "Greased-leader in the film"),
                Pick(name: "Black Beauty #20–22", note: "Dropper in slow, clear runs"),
                Pick(name: "RS2 #22", note: "Tiny emerger when fish are picky")
            ]
        case .stonefly:
            return [
                Pick(name: "Stonefly Nymph #8–10", note: "Dead-drift deep along the rocks"),
                Pick(name: "Rubber-Leg Stone #6–8", note: "Bounce the bottom of runs"),
                Pick(name: "Prince Nymph #12", note: "Searching dropper"),
                Pick(name: "Copper John #12–14", note: "Weighted dropper to get down"),
                Pick(name: "Hares Ear Nymph #12", note: "Natural searching pattern")
            ]
        case .none:
            return nil // JS: M[h] || null
        }
    }

    // MARK: - picksOverride(s)  (JS: function picksOverride(s))

    private static func picksOverride(_ s: Scenario) -> [Pick]? {
        let m = s.method, sp = s.species, cl = s.clarity, t = s.temp, d = s.depth
        let fc = (t == .frigid || t == .cold)
        let wh = (t == .warm || t == .hot)
        let off = (cl == .muddy || cl == .stained)
        let deep = (d == .deep)
        if sp == .smallmouth && m == .fly {
            if wh && d == .shallow {
                return [
                    Pick(name: "Deer Hair Popper #4-6", note: "Topwater over the flats at dawn and dusk"),
                    Pick(name: "Sneaky Pete Popper #6", note: "Subtle topwater along the bank"),
                    Pick(name: "Olive Goby Streamer #4-6", note: "Strip along the rocky banks"),
                    Pick(name: "Chartreuse/white Clouser #4", note: "Dart over the flats for active fish"),
                    Pick(name: "Crayfish Pattern #6", note: "Crawl through the rocks")
                ]
            }
            if off {
                return [
                    Pick(name: "Chartreuse/white Clouser Minnow #4", note: "Bright baitfish profile for off-color water"),
                    Pick(name: "Black/olive bulky Bugger #2", note: "Dark, high-contrast silhouette in stained current"),
                    Pick(name: "Gold Clouser #4", note: "Flash over the rocks in stained flow"),
                    Pick(name: "White Murdich Minnow #4", note: "Pushes water and shows up in low visibility"),
                    Pick(name: "Chartreuse crayfish pattern #6", note: "Crawl bottom with a visible color")
                ]
            }
            if fc {
                return [
                    Pick(name: "Olive sculpin streamer #4", note: "Slow swing low through the deeper pools"),
                    Pick(name: "Brown Woolly Bugger #6", note: "Dead-drift deep and slow for cold fish"),
                    Pick(name: "Marabou leech (natural)", note: "Crawl near bottom through holding water"),
                    Pick(name: "Goby streamer (natural) #4", note: "Slow strip over rock - skip the fast stripping"),
                    Pick(name: "Small Clouser (natural) #6", note: "Subtle profile for a sluggish bite")
                ]
            }
            return [
                Pick(name: "Olive Goby / Sculpin Streamer #4-6", note: "Strip and pause over rocky bottom"),
                Pick(name: "Crayfish Pattern #6", note: "Crawl through the rocks - a Rocky River staple"),
                Pick(name: "Clouser Minnow (olive/white) #4", note: "Cover seams and current breaks"),
                Pick(name: "Woolly Bugger (olive/black) #6", note: "Dead-drift or swing the seams"),
                Pick(name: "Murdich Minnow #4", note: "Baitfish profile through the deeper pools")
            ]
        }
        if sp == .catfish && m == .fly && fc {
            return [
                Pick(name: "Weighted black bunny leech", note: "Cold cats are sluggish - dredge slow and deep"),
                Pick(name: "Large dark articulated streamer", note: "Big, slow profile near the bottom of the holes"),
                Pick(name: "Flesh / worm fly", note: "Dead-slow drift through the deepest water"),
                Pick(name: "Heavy olive sculpin #2", note: "Crawl bottom and keep it slow"),
                Pick(name: "Black/purple leech", note: "Subtle, slow swing in the deep pools")
            ]
        }
        if sp == .catfish && m == .pin && fc {
            return [
                Pick(name: "Cut bait (shad) under a float - deep and slow", note: "Cold cats barely move - put scent right on them"),
                Pick(name: "Nightcrawler gob under a float", note: "Slow drift through the deepest holes"),
                Pick(name: "Cured shrimp under a float", note: "Easy scent for a sluggish cold bite"),
                Pick(name: "Chicken liver under a float", note: "Soak the slow, deep eddies"),
                Pick(name: "Live shad under a float", note: "Natural movement low in the water column")
            ]
        }
        if sp == .smallmouth && m == .pin {
            if cl == .muddy {
                return [
                    Pick(name: "Chartreuse/orange jig + minnow under a float", note: "Bright profile bass can track in dirty water"),
                    Pick(name: "Black/blue tube under a float", note: "Dark, high-contrast silhouette through stained current"),
                    Pick(name: "Gold-blade hair jig (orange) under a float", note: "Flash and color for low visibility"),
                    Pick(name: "Live minnow under a float", note: "Scent and movement when sight is limited"),
                    Pick(name: "White marabou jig under a float", note: "High-vis swimming profile in murky water")
                ]
            }
            if cl == .stained {
                return [
                    Pick(name: "Chartreuse/white jig + minnow under a float", note: "Contrast that shows up in tea-colored water"),
                    Pick(name: "Tube - black/blue or junebug under a float", note: "Bolder color drifted over rocky pools"),
                    Pick(name: "Orange bead / hair jig under a float", note: "A little flash and a hot spot"),
                    Pick(name: "Live minnow or crayfish under a float", note: "Natural drift through holding water"),
                    Pick(name: "Soft bead (orange) under a float", note: "Visible egg on a drag-free drift")
                ]
            }
            if fc {
                return [
                    Pick(name: "1/16-1/8 oz hair jig (brown/olive) under a float", note: "Crawl slowly - cold bass want an easy, subtle target"),
                    Pick(name: "Downsized tube - green pumpkin under a float", note: "Dead-slow drift just off bottom in the deeper pools"),
                    Pick(name: "Live minnow under a float", note: "Hard to beat when the bite is cold and tough"),
                    Pick(name: "Soft bead (natural) under a float", note: "Subtle, drag-free drift through the slow runs"),
                    Pick(name: "Micro jig + waxworm under a float", note: "Finesse for lethargic smallmouth")
                ]
            }
            return [
                Pick(name: "Tube under a float - green pumpkin / goby", note: "Natural color suspended over rocky pools" + (deep ? " - add weight to ride just off bottom" : "")),
                Pick(name: "1/8 oz jig + minnow under a float", note: "Drift the seams just off bottom"),
                Pick(name: "Live minnow or crayfish under a float", note: "Natural drift through holding water"),
                Pick(name: "Soft bead (natural / peach) under a float", note: "Match the forage on a drag-free drift"),
                Pick(name: "Hair jig (brown) under a float", note: "Slow, natural presentation over rock")
            ]
        }
        if sp == .walleye && m == .fly {
            if off {
                return [
                    Pick(name: "Chartreuse/white Clouser Minnow #2-4", note: "Bright baitfish profile for off-color water"),
                    Pick(name: "Gold Clouser Minnow #2", note: "Flash near bottom in stained flow"),
                    Pick(name: "White Zonker / bunny streamer #2", note: "High-vis swimming profile through the slots"),
                    Pick(name: "Chartreuse marabou jig-fly", note: "Color and movement low and slow"),
                    Pick(name: "Orange-bead leech pattern", note: "A hot spot fish can track in dirty water")
                ]
            }
            if fc {
                return [
                    Pick(name: "White/olive bunny leech #2", note: "Slow swing low through the deep slots"),
                    Pick(name: "Marabou jig-fly (brown)", note: "Hop slowly near bottom in cold pools"),
                    Pick(name: "Gold Clouser Minnow #2", note: "Slow strip just off bottom"),
                    Pick(name: "Sculpin streamer #4", note: "Bounce bottom through deeper holding water"),
                    Pick(name: "Weighted black Woolly Bugger #4", note: "Dead-drift the bottom of the holes")
                ]
            }
            return [
                Pick(name: "Olive/white Clouser Minnow #2-4", note: "Natural baitfish strip near bottom"),
                Pick(name: "Gold Clouser Minnow #2", note: "Subtle flash over the slots"),
                Pick(name: "Olive sculpin streamer #4", note: "Crawl the rocky bottom and seams"),
                Pick(name: "Marabou jig-fly (natural)", note: "Hop slowly through deeper runs"),
                Pick(name: "White bunny streamer #2", note: "Slow swing through low-light holding water")
            ]
        }
        if sp == .walleye && m == .pin {
            if off {
                return [
                    Pick(name: "Chartreuse jig + minnow under a float", note: "Bright color walleye can find in stained flow"),
                    Pick(name: "Orange/gold bead under a float", note: "High-vis for low light and color"),
                    Pick(name: "Glow / white swim jig under a float", note: "Stands out in off-color water"),
                    Pick(name: "Float + jig and nightcrawler", note: "Scent and color through the slots"),
                    Pick(name: "Gold-blade hair jig under a float", note: "Flash for murky, pushy water")
                ]
            }
            if fc {
                return [
                    Pick(name: "1/8 oz jig + minnow under a float (slow)", note: "Cold walleye want a slow, near-bottom drift"),
                    Pick(name: "Hair jig (brown/olive) under a float", note: "Subtle profile crawled through deep slots"),
                    Pick(name: "Live minnow under a float", note: "Best bet when the bite is cold and tough"),
                    Pick(name: "Soft bead (natural) under a float", note: "Slow, drag-free drift in the deeper pools"),
                    Pick(name: "Blade bait (silver) - vertical", note: "Lift-drop in deep slots for inactive fish")
                ]
            }
            return [
                Pick(name: "Jig + minnow under a float", note: "Suspend near bottom in the slots" + (deep ? " - add weight for the deep holes" : "")),
                Pick(name: "Soft bead (natural) under a float", note: "Drift the deeper runs"),
                Pick(name: "White/chartreuse swim jig under a float", note: "Slow drift in low light"),
                Pick(name: "Float + nightcrawler", note: "Natural drift near the mouth at dusk"),
                Pick(name: "Hair jig (brown) under a float", note: "Slow presentation through holding water")
            ]
        }
        if sp == .catfish && m == .fly {
            if off {
                return [
                    Pick(name: "Large white/chartreuse articulated streamer", note: "Big, bright profile cats can track in dirty water"),
                    Pick(name: "Black/red bulky bunny leech", note: "High-contrast silhouette dredged near bottom"),
                    Pick(name: "Heavy chartreuse Clouser #1/0", note: "Bright flash low in off-color current"),
                    Pick(name: "Pink flesh / worm fly", note: "Drift slow along the bottom in eddies"),
                    Pick(name: "White game-changer streamer", note: "Lots of movement to draw a reaction")
                ]
            }
            return [
                Pick(name: "Large white articulated streamer", note: "Strip slow along the bottom of deep holes"),
                Pick(name: "Weighted black bunny leech", note: "Dredge the deepest holding water"),
                Pick(name: "Heavy Clouser Minnow #1/0", note: "Get down to the cats near bottom"),
                Pick(name: "Flesh / worm fly", note: "Dead-drift slow through the slow eddies"),
                Pick(name: "Olive sculpin streamer #2", note: "Crawl bottom near cover - niche, but it works")
            ]
        }
        if sp == .catfish && m == .pin {
            if off {
                return [
                    Pick(name: "Cut bait (shad/bluegill) under a float", note: "Scent trail cats home in on in dirty water"),
                    Pick(name: "Stink / punch bait under a float", note: "Maximum scent for low visibility"),
                    Pick(name: "Chicken liver under a float", note: "Classic scent bait drifted through the holes"),
                    Pick(name: "Nightcrawler gob under a float", note: "Soak the slow eddies on a drifting float"),
                    Pick(name: "Shrimp on a circle hook under a float", note: "Easy, scenty target near the bottom")
                ]
            }
            return [
                Pick(name: "Cut bait (shad/bluegill) under a float", note: "Drift scent through the deep pools"),
                Pick(name: "Live or fresh shad under a float", note: "Natural movement near bottom in clearer water"),
                Pick(name: "Nightcrawler gob under a float", note: "Soak the holes and slow inside seams"),
                Pick(name: "Cured shrimp under a float", note: "Scent in the slow eddies"),
                Pick(name: "Chicken liver under a float", note: "Classic channel-cat bait drifted slow")
            ]
        }
        return nil
    }

    // MARK: - picks(s)  (JS: function picks(s))

    static func picks(_ s: Scenario) -> [Pick] {
        let m = s.method, sp = s.species, cl = s.clarity, t = s.temp, d = s.depth
        let fc = (t == .frigid || t == .cold)
        let wh = (t == .warm || t == .hot)
        // JS: var _po=picksOverride(s);if(_po)return _po;
        if let po = picksOverride(s) { return po }
        if m == .fly {
            // JS: if((sp==='steelhead'||sp==='smallmouth')&&s.hatch&&s.hatch!=='none'){var hp=hatchPicks(s.hatch);if(hp)return hp;}
            if (sp == .steelhead || sp == .smallmouth), let h = s.hatch, h != Hatch.none {
                if let hp = hatchPicks(h) { return hp }
            }
            if sp == .steelhead {
                if cl == .muddy {
                    return [
                        Pick(name: "Dark Intruder #2–4", note: "Big, dark profile fish can find in dirty water"),
                        Pick(name: "Egg-Sucking Leech", note: "Swing slow through soft holding water"),
                        Pick(name: "Pink Worm", note: "High-vis along the bottom in bank eddies"),
                        Pick(name: "Estaz Egg (chartreuse/orange) #8", note: "Bright, flashy egg for low visibility"),
                        Pick(name: "Black/Blue Woolly Bugger #4", note: "Dark silhouette swung through the slots")
                    ]
                }
                if fc {
                    return [
                        Pick(name: "Glo Bug Egg #10–12", note: "Dead-drift the tailouts; the winter staple"),
                        Pick(name: "Stonefly Nymph #8–10", note: "Add shot to reach the deeper slots"),
                        Pick(name: "Sucker Spawn", note: "Natural orange or pale, drag-free"),
                        Pick(name: "Crystal Meth Egg #10–12", note: "Bright egg for cold, clear flows"),
                        Pick(name: "Hares Ear Nymph #12–14", note: "Natural dropper below the egg")
                    ]
                }
                return [
                    Pick(name: "Glo Bug Egg #10–12", note: "Dead-drift the runs and tailouts"),
                    Pick(name: "Pheasant Tail Nymph #10–14", note: "Natural dropper below the egg"),
                    Pick(name: "Marabou Spey Fly", note: "Swing through classic runs in prime temps"),
                    Pick(name: "Egg-Sucking Leech (black/purple)", note: "Swing the soft inside seams"),
                    Pick(name: "Green Caddis Larva #14", note: "Searching nymph when fish are active")
                ]
            }
            if sp == .smallmouth {
                if wh && d == .shallow {
                    return [
                        Pick(name: "Deer Hair Popper #4–6", note: "Topwater over flats at dawn and dusk"),
                        Pick(name: "Olive Goby Streamer #4–6", note: "Strip along the rocky banks"),
                        Pick(name: "Crayfish Pattern #6", note: "Crawl through the rocks"),
                        Pick(name: "Clouser Minnow (chartreuse/white) #4", note: "Dart over the flats for active fish"),
                        Pick(name: "Sneaky Pete Popper #6", note: "Subtle topwater along the banks")
                    ]
                }
                return [
                    Pick(name: "Olive Goby / Sculpin Streamer #4–6", note: "Strip and pause along rocky bottoms"),
                    Pick(name: "Crayfish Pattern #6", note: "Crawl the rocky runs — a Rocky River staple"),
                    Pick(name: "Clouser Minnow (olive/white) #4", note: "Cover seams and current breaks"),
                    Pick(name: "Woolly Bugger (olive/black) #6", note: "Dead-drift or swing the seams"),
                    Pick(name: "Murdich Minnow #4", note: "Baitfish profile through deeper pools")
                ]
            }
            if sp == .walleye {
                return [
                    Pick(name: "Chartreuse/White Clouser #2–4", note: "Strip slowly near bottom in low light"),
                    Pick(name: "Dark Articulated Streamer", note: "Swing seams after dark"),
                    Pick(name: "Marabou Jig-Fly", note: "Hop near the bottom in the slots"),
                    Pick(name: "White Zonker / Bunny Streamer #2", note: "Slow swing through deep runs"),
                    Pick(name: "Gold Clouser Minnow #2", note: "Flash near bottom in stained water")
                ]
            }
            return [
                Pick(name: "Large Black Articulated Streamer", note: "Crawl slow through deep holes — niche only"),
                Pick(name: "Dark Woolly Bugger #2", note: "Dead-drift the bottom of holes"),
                Pick(name: "Leech Pattern", note: "Slow swing in deep, slow water"),
                Pick(name: "Black/Olive Sculpin Streamer #2", note: "Bounce bottom in slow pools"),
                Pick(name: "Heavy Bunny Leech", note: "Dredge the deepest holding water")
            ]
        }
        if m == .spin {
            if sp == .steelhead {
                if cl == .clear {
                    return [
                        Pick(name: "Silver/Gold Spoon (Little Cleo, 1/4–3/8 oz)", note: "Cast up and across; sink, then slow-roll just off bottom"),
                        Pick(name: "Silver Inline Spinner (Vibrax / Mepps #3)", note: "Retrieve just fast enough to feel the blade"),
                        Pick(name: "Float + 1/16 oz jig and maggots", note: "Suspend just off bottom through runs"),
                        Pick(name: "Natural soft bead (8–10 mm) under a float", note: "Subtle egg in clear water"),
                        Pick(name: "Kwikfish / Mag Lip plug", note: "Wobble through the deeper runs")
                    ]
                }
                if cl == .muddy {
                    return [
                        Pick(name: "Chartreuse/Orange Spoon", note: "Loud, bright profile for low visibility"),
                        Pick(name: "Bright jig (chartreuse/pink) under a float", note: "Slow it down near the bottom"),
                        Pick(name: "14 mm bright bead drifted on bottom", note: "Bounce through holding water"),
                        Pick(name: "Colorado-blade Spinner (chartreuse)", note: "Max vibration so fish find it"),
                        Pick(name: "Cured spawn sac (bright mesh)", note: "Scent and bulk in dirty water")
                    ]
                }
                return [
                    Pick(name: "Gold/Orange Spoon (Little Cleo)", note: "Flash and contrast for stained flow"),
                    Pick(name: "Chartreuse-blade Vibrax Spinner", note: "Slow, steady retrieve"),
                    Pick(name: "Pink/Orange jig under a float", note: "Drift the seams just off bottom"),
                    Pick(name: "10–12 mm orange bead under a float", note: "Drift the runs just off bottom"),
                    Pick(name: "Cured spawn sac", note: "Natural scent during the egg bite")
                ]
            }
            if sp == .smallmouth {
                if cl == .muddy || cl == .stained {
                    return [
                        Pick(name: "Rebel Craw (rocky sections)", note: "Crank tight to the rocks"),
                        Pick(name: "Chartreuse Spinnerbait", note: "Vibration and flash in off-color water"),
                        Pick(name: "3 in Tube — dark/black", note: "Bottom-drag the seams"),
                        Pick(name: "Chatterbait (chartreuse/white)", note: "Thump through stained current"),
                        Pick(name: "Colorado-blade Spinner (gold)", note: "Slow-roll the seams")
                    ]
                }
                if fc {
                    return [
                        Pick(name: "Drop-shot worm", note: "Finesse over rock when the bite is tough"),
                        Pick(name: "Ned Rig — green pumpkin", note: "Slow and subtle in deeper pools"),
                        Pick(name: "3 in Tube — natural", note: "Dead-drag the bottom"),
                        Pick(name: "Hair jig (brown/olive) 1/8 oz", note: "Crawl slowly through cold pools"),
                        Pick(name: "Blade bait (silver)", note: "Lift-drop vertically in deep slots")
                    ]
                }
                return [
                    Pick(name: "3 in Tube — green pumpkin / goby (1/8–1/4 oz)", note: "Drag and hop over rocky bottom"),
                    Pick(name: "Ned Rig — green pumpkin", note: "Deadly in slower pools and seams"),
                    Pick(name: "Jerkbait — shad / minnow", note: "Twitch through current breaks"),
                    Pick(name: "Crawfish Square-bill Crankbait", note: "Deflect off the rocks"),
                    Pick(name: "Inline Spinner (Mepps #2–3, gold)", note: "Cover riffles and runs")
                ]
            }
            if sp == .walleye {
                if cl == .clear {
                    return [
                        Pick(name: "Shallow stickbait (Husky Jerk / Rapala P10)", note: "Cast and slow-retrieve after dark"),
                        Pick(name: "Jig + minnow or twister (1/8–1/4 oz)", note: "Hop near bottom in the slots"),
                        Pick(name: "Silver blade bait", note: "Lift-drop in deeper runs"),
                        Pick(name: "Hair jig + minnow (1/8 oz)", note: "Slow vertical presentation in current"),
                        Pick(name: "Suspending jerkbait (natural shad)", note: "Long pauses in cold, clear water")
                    ]
                }
                return [
                    Pick(name: "Chartreuse / firetiger stickbait", note: "Night casting near the mouth"),
                    Pick(name: "Jig + chartreuse twister", note: "Bottom hop through slots"),
                    Pick(name: "Gold blade bait", note: "Vibration in off-color water"),
                    Pick(name: "Jig + nightcrawler (1/4 oz)", note: "Drag the slots and current seams"),
                    Pick(name: "Firetiger crankbait", note: "Cover the lower river and mouth")
                ]
            }
            if cl == .muddy {
                return [
                    Pick(name: "Stink / punch bait", note: "Scent shines in dirty water"),
                    Pick(name: "Cut bait — shad or bluegill", note: "Bottom rig in the holes"),
                    Pick(name: "Chicken liver", note: "Near the mouth and deep pools"),
                    Pick(name: "Shrimp on a circle hook", note: "Easy scent bait on the bottom"),
                    Pick(name: "Nightcrawler gob", note: "Soak the slow eddies")
                ]
            }
            return [
                Pick(name: "Cut bait — shad or bluegill", note: "Slip-sinker rig in deep holes"),
                Pick(name: "Chicken liver", note: "Classic channel-cat bait on the bottom"),
                Pick(name: "Nightcrawler gob", note: "Soak in holes and near the mouth"),
                Pick(name: "Live or dead shad", note: "Bottom rig the deepest pools"),
                Pick(name: "Prepared dip bait (tube)", note: "Scent trail in slow water")
            ]
        }
        if sp == .steelhead {
            if cl == .clear {
                return [
                    Pick(name: "8 mm soft bead (natural / peach)", note: "Drift drag-free just off bottom"),
                    Pick(name: "1/16 oz jig + maggots (black/white)", note: "Suspend through the runs"),
                    Pick(name: "Stonefly nymph under the float", note: "Bounce the deeper slots"),
                    Pick(name: "Natural spawn sac (light mesh)", note: "Subtle scent in clear water"),
                    Pick(name: "Pheasant Tail nymph under the float", note: "Natural dropper through the runs")
                ]
            }
            if cl == .muddy {
                return [
                    Pick(name: "14–19 mm bead (bright orange/chartreuse)", note: "Big bright target in dirty water"),
                    Pick(name: "Chartreuse jig under the float", note: "Slow and low near the bottom"),
                    Pick(name: "Cured spawn sac", note: "Scent and bulk help fish find it"),
                    Pick(name: "Pink worm under the float", note: "High-vis profile near the bottom"),
                    Pick(name: "Estaz egg fly (chartreuse)", note: "Flash for low visibility")
                ]
            }
            return [
                Pick(name: "10–12 mm bead (orange/pink)", note: "Visible egg imitation through the runs"),
                Pick(name: "1/8 oz pink jig + maggots", note: "Drift the seams just off bottom"),
                Pick(name: "Cured spawn sac", note: "Naturals shine during the egg bite"),
                Pick(name: "8 mm soft bead (peach/natural)", note: "Match the egg drift in stained flow"),
                Pick(name: "Stonefly nymph under the float", note: "Dropper for the deeper slots")
            ]
        }
        if sp == .smallmouth {
            return [
                Pick(name: "Tube under a float", note: "Suspend over rocky pools"),
                Pick(name: "1/8 oz jig + minnow", note: "Drift the seams just off bottom"),
                Pick(name: "Live minnow or crayfish", note: "Natural drift through holding water"),
                Pick(name: "Soft bead (natural)", note: "Drift the deeper runs"),
                Pick(name: "Hair jig (brown) under a float", note: "Slow presentation over rock")
            ]
        }
        if sp == .walleye {
            return [
                Pick(name: "Jig + minnow under a float", note: "Suspend near bottom in the slots"),
                Pick(name: "Soft bead (natural)", note: "Drift the deeper runs"),
                Pick(name: "Swim jig (white/chartreuse)", note: "Slow drift in low light"),
                Pick(name: "Float + nightcrawler", note: "Natural drift through the slots"),
                Pick(name: "Hair jig + minnow", note: "Slow it down near bottom after dark")
            ]
        }
        return [
            Pick(name: "Cut bait under a slip float", note: "Park over deep holes — niche"),
            Pick(name: "Nightcrawler", note: "Drift the slow, deep water"),
            Pick(name: "Stink bait", note: "Scent in off-color holes"),
            Pick(name: "Cured shrimp under a float", note: "Scent in the slow eddies"),
            Pick(name: "Live shad under a float", note: "Suspend over the deepest holes")
        ]
    }

    // MARK: - why(s)  (JS: function why(s))

    static func why(_ s: Scenario) -> WhyThisRig {
        let sp = s.species, cl = s.clarity, t = s.temp, cu = s.current, d = s.depth, m = s.method
        let hl = "Built for " + speciesName(sp) + " on the Rocky River — " + methodName(m) + ", " + d.rawValue + " / " + cu.rawValue + " water at " + tempLabel(t) + ", " + cl.rawValue + " clarity."
        let whereText: String
        switch sp {
        case .steelhead: whereText = "Steelhead hold in tailouts, riffle heads, and soft water below faster flow from fall through spring."
        case .smallmouth: whereText = "Smallmouth relate to rocky runs, current seams, and deeper pools through the warmer months."
        case .walleye: whereText = "Walleye push into the lower river to feed on high water and after dark, especially near the mouth."
        case .catfish: whereText = "Channel cats hold in the deeper, slower holes — best near the mouth and Emerald Necklace Marina."
        }
        let flowBase: String
        switch cu {
        case .slow: flowBase = "Low, slow flow — fish spook easily, so lengthen leaders and slow down."
        case .moderate: flowBase = "Moderate flow is ideal — the river reads well and fish hold predictably."
        case .fast: flowBase = "High, pushy water — get heavier and fish soft edges and seams."
        // Fixed vs. the web engine: the JS flow map has no 'still' key and renders
        // the literal string "undefined" here. Golden-master tests special-case this.
        case .still: flowBase = "Still, frog-water sections — fish it like a pond: cover water methodically and let the fish tell you the pace."
        }
        let flow = flowBase + " The Rocky fishes best around 150–250 cfs."
        let temp: String
        if sp == .steelhead {
            switch t {
            case .frigid: temp = "Deep winter — fish slow and deep with eggs and beads."
            case .cold: temp = "Prime steelhead water — fish will chase a swung fly or lure."
            case .prime: temp = "Early or late season — steelhead are aggressive but moving out as it warms."
            case .warm: temp = "Too warm — steelhead have left the river."
            case .hot: temp = "Too warm — steelhead have left the river."
            }
        } else if sp == .smallmouth {
            switch t {
            case .frigid: temp = "Very cold — bass barely feed; go slow and deep."
            case .cold: temp = "Cold and sluggish — finesse presentations only."
            case .prime: temp = "Prime smallmouth water — active and willing."
            case .warm: temp = "Peak season — aggressive feeding, top to bottom."
            case .hot: temp = "Hot — fish dawn and dusk; rest midday in cooler, deeper pools."
            }
        } else if sp == .walleye {
            temp = "Walleye bite best in low light — dawn, dusk, and after dark; high water pulls them upriver."
        } else {
            switch t {
            case .frigid: temp = "Cold — catfish are sluggish; very slow presentations."
            case .cold: temp = "Cool — slow bite; soak bait longer."
            case .prime: temp = "Good feeding — cats are active in the holes."
            case .warm: temp = "Prime catfish water — aggressive and feeding."
            case .hot: temp = "Hot — strong evening and night bite in the deep holes."
            }
        }
        let clar: String
        if m == .spin {
            switch cl {
            case .clear: clar = "Clear water — natural silver/gold and finesse colors."
            case .stained: clar = "Stained water — orange, gold, and chartreuse accents."
            case .muddy: clar = "Muddy water — loud chartreuse/orange and vibration."
            }
        } else {
            switch cl {
            case .clear: clar = "Clear water — downsize, go natural, and lengthen leaders."
            case .stained: clar = "Stained water — add a little size, contrast, or flash."
            case .muddy: clar = "Muddy water — go big, bright, and slow, tight to structure."
            }
        }
        return WhyThisRig(headline: hl, rows: [
            RigRow(label: "Where", value: whereText),
            RigRow(label: "Flow", value: flow),
            RigRow(label: "Temp", value: temp),
            RigRow(label: "Clarity", value: clar)
        ])
    }

    // MARK: - proTipOverride(s)  (JS: function proTipOverride(s))

    private static func proTipOverride(_ s: Scenario) -> String? {
        let sp = s.species, m = s.method, t = s.temp, cl = s.clarity, cu = s.current
        let fc = (t == .frigid || t == .cold)
        let off = (cl == .muddy || cl == .stained)
        let fast = (cu == .fast)
        if sp == .smallmouth && m == .pin {
            var b: String
            if fc {
                b = "In cold water slow the drift right down and downsize - a small hair jig, tube, or live minnow under the float, ticking bottom through the deeper pools."
            } else if off {
                b = "In off-color water go brighter - chartreuse or orange jigs and beads, or a dark high-contrast tube - and keep the float drifting slow and close to bottom."
            } else {
                b = "Suspend a tube, jig and minnow, or live crayfish just off the bottom and drift it naturally through the rocky pools and seams; green pumpkin and goby colors match the forage in clearer water."
            }
            if fast { b += " High flow - add a little weight to hold the drift in the seams." }
            return b
        }
        if sp == .walleye {
            var b = "Walleye are a low-light bite - work the lower river near the mouth at dusk and after dark, and during higher water when they push upstream."
            if off {
                b += " In stained water lean on chartreuse, orange, and gold."
            } else {
                b += " In clear water downsize and go natural."
            }
            if fc { b += " Cold water - short cadence with long pauses between lifts." }
            return b
        }
        if sp == .catfish {
            var c = "Cats are a scent game - soak cut bait, nightcrawlers, or shrimp on the bottom (or under a slip float) in the deep holes and near the mouth."
            if off { c += " Dirty water actually helps - stink and punch baits put out a scent trail they follow." }
            if fast { c += " In high flow, pin baits to the bottom on the soft inside seams." }
            return c
        }
        return nil
    }

    // MARK: - proTip(s)  (JS: function proTip(s))

    static func proTip(_ s: Scenario) -> String {
        let sp = s.species, m = s.method, t = s.temp
        let fc = (t == .frigid || t == .cold)
        let wh = (t == .warm || t == .hot)
        // JS: var _pt=proTipOverride(s);if(_pt)return _pt;
        if let pt = proTipOverride(s) { return pt }
        if sp == .steelhead && wh {
            return "Steelhead leave the Rocky River once it warms in late spring — switch your target to smallmouth bass for the summer."
        }
        if sp == .steelhead {
            if m == .pin {
                return "Set your float so the bait just ticks bottom occasionally, and mend for a slow, drag-free drift at current speed — that natural presentation gets the most takes."
            }
            if m == .spin {
                return "Cast spoons up and across, let them sink, and slow-roll just off bottom; orange and gold shine in stained Rocky River flows, silver in clear water."
            }
            return "Dead-drift eggs and nymphs through the tailouts and keep your drift drag-free; the river fishes best between 150 and 250 cfs."
        }
        if sp == .smallmouth {
            if m == .fly {
                if fc {
                    return "In cold water slow down — swing or dead-drift a sculpin, crayfish, or Woolly Bugger deep and slow through the pools instead of stripping fast."
                }
                return "Strip and pause crayfish and goby / sculpin streamers over rocky bottom and current seams; olive and natural baitfish colors match what smallmouth feed on here."
            }
            if m == .pin {
                return "Suspend a tube, jig and minnow, or live crayfish just off the bottom and drift it naturally through the rocky pools and seams."
            }
            if fc {
                return "In cold water slow everything down — drag a tube, Ned rig, or drop-shot through the deeper pools rather than fishing fast."
            }
            return "Work tubes and Ned rigs slowly over rocky bottom and current seams; green pumpkin and goby colors match the gobies and crayfish smallmouth feed on here."
        }
        if sp == .walleye {
            return "Walleye are a low-light bite — fish the lower river near the mouth at dusk and after dark, and focus on higher-water periods when they push upstream."
        }
        if m == .fly || m == .pin {
            return "Cats are really a bait-fishing target — a cut-bait or nightcrawler bottom rig in the deep holes will out-fish a fly or float by a wide margin."
        }
        return "Anchor a cut-bait or nightcrawler bottom rig in the deeper holes; the water near the mouth and the marina holds the bigger channel cats, best in the evening."
    }
}
