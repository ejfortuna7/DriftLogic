import Foundation

/// Mechanical port of the technique-video logic from the verified web engine
/// (driftlogic-engine-reference.js): `vidsFor(s)` and the `VID` metadata map.
/// IDs and ordering must match the JS exactly. HTML entities in titles are
/// decoded (&amp; → "&").
enum VideoLibrary {

    // MARK: - vidsFor(s)  (JS: function vidsFor(s))
    // The JS returns [] when species is missing; in Swift species is always set,
    // so only the species branches are ported.

    static func videoIDs(for s: Scenario) -> [String] {
        let sp = s.species, m = s.method
        if sp == .steelhead {
            if m == .pin { return ["tv4ReejGg8M", "G-pmvPEV0SM", "nhvzDUGo6kw", "rmAcLX7aJXw", "RwBtJKHbOsU"] }
            if m == .spin { return ["fdHhz1zuRFA", "kTdAl6ZDnvM", "Q0G-vg4yhcM", "JOWSWhJgwoM", "OZhK53Q_kDE"] }
            return ["PZvCxmD0Fwk", "eRZvuH_nwq8", "dNUgK5vbiR8", "OqsnpvXRfBU", "vdN7Vj7XtSA"]
        }
        if sp == .smallmouth {
            if m == .pin { return ["LqQa66veMuM", "DEvz6ZlSlms", "p-OUz1EeIdU", "NQxTW8le6lw", "f5GxwYPPFi0"] }
            if m == .spin { return ["8Mss49ZiFCA", "OhPgsCsBDPQ", "ivGuVb9gku4", "lNid3sV6AHM", "yekBwnFxiKA"] }
            return ["V6U0-dPF50E", "oVBDdmXboq4", "E5pFMCBDi6c", "vwMNmlIoos8", "L-Lvlcrx3HY"]
        }
        if sp == .walleye {
            if m == .pin { return ["INLubW9RfL8", "bwrKo4bV-_0", "q99pVDQg16g", "WnD2llfdFa4", "7Kgit5UU-bw"] }
            if m == .spin { return ["7FcYt3DjcS8", "puovlhVEOhM", "tWzWdmgHnu8", "wB6QPtCQoRk", "ovb4Yt_mIJg"] }
            return ["Q0RWBkxn_dY", "8_PcB79EPpk", "vdNr_GWhuZ0", "NZN1OMwVy5k", "S1vNRfzkgl8"]
        }
        // catfish
        if m == .pin { return ["Tzcn8flc3cQ", "6D79iHbyyAY", "Te-jpvnw54Q", "GnUsD-OSjLc", "6TEUws2C9Wc"] }
        if m == .spin { return ["_Ot2XvVEgHA", "_vtZSyzqux0", "iLeI8uxaCHA", "EgbBeCBHang", "WQAej-2mIg4"] }
        return ["kfwh7hBbCHM", "0hoD65Zv5sE", "RIRGG14X8oY", "dzIPgyNgl8I", "RF6Wx5BplC4"]
    }

    // MARK: - VID map  (JS: var VID = {...}, 29 entries)

    static let labels: [String: VideoInfo] = [
        "PZvCxmD0Fwk": VideoInfo(id: "PZvCxmD0Fwk", title: "Indicator & Euro Nymphing", channel: "Orvis Guide to Fly Fishing"),
        "eRZvuH_nwq8": VideoInfo(id: "eRZvuH_nwq8", title: "Indicator Nymphing: Gear & Rigging", channel: "The Northern Angler"),
        "dNUgK5vbiR8": VideoInfo(id: "dNUgK5vbiR8", title: "Steelhead on the Swing (Spey)", channel: "Travel Fish Film"),
        "tv4ReejGg8M": VideoInfo(id: "tv4ReejGg8M", title: "Center-Pin Casting & Rigging", channel: "West Michigan Guide Service"),
        "G-pmvPEV0SM": VideoInfo(id: "G-pmvPEV0SM", title: "How to Fish a Center-Pin Setup", channel: "On The Water"),
        "nhvzDUGo6kw": VideoInfo(id: "nhvzDUGo6kw", title: "Center-Pin Steelhead Basics", channel: "Average Ontario Anglers"),
        "fdHhz1zuRFA": VideoInfo(id: "fdHhz1zuRFA", title: "3 Best Ways to Float Fish", channel: "Addicted Fishing"),
        "kTdAl6ZDnvM": VideoInfo(id: "kTdAl6ZDnvM", title: "Float Fishing: In-Depth How-To", channel: "Addicted Fishing"),
        "Q0G-vg4yhcM": VideoInfo(id: "Q0G-vg4yhcM", title: "Spinner Fishing for Steelhead", channel: "Addicted Fishing"),
        "8Mss49ZiFCA": VideoInfo(id: "8Mss49ZiFCA", title: "The Tube Trick for Smallmouth", channel: "TacticalBassin"),
        "OhPgsCsBDPQ": VideoInfo(id: "OhPgsCsBDPQ", title: "Summer Topwater River Smallmouth", channel: "Kzoo Kayak Fishing"),
        "ivGuVb9gku4": VideoInfo(id: "ivGuVb9gku4", title: "Jigging River Smallmouth & Walleye", channel: "Tim Galati"),
        "pcU_idmsm48": VideoInfo(id: "pcU_idmsm48", title: "How to Fish a Jig: River Walleye", channel: "Angler X Outdoors"),
        "guHqijb8fMg": VideoInfo(id: "guHqijb8fMg", title: "Jigging for River Walleye", channel: "MrBluegill"),
        "UYd8GvhHHDc": VideoInfo(id: "UYd8GvhHHDc", title: "Three Catfish Rigs", channel: "Dieter Melhorn Fishing"),
        "uMamCVwaA5o": VideoInfo(id: "uMamCVwaA5o", title: "3 Best Catfish Rigs", channel: "Dieter Melhorn Fishing"),
        "PUGC8NCh9is": VideoInfo(id: "PUGC8NCh9is", title: "Simple Kentucky Catfish Rig", channel: "Fishing Explained"),
        "OqsnpvXRfBU": VideoInfo(id: "OqsnpvXRfBU", title: "Fly Fishing for Great Lakes Steelhead", channel: "Orvis Guide to Fly Fishing"),
        "vdN7Vj7XtSA": VideoInfo(id: "vdN7Vj7XtSA", title: "Nymph Set-Up: Great Lakes Steelhead", channel: "Payton Hanssen"),
        "rmAcLX7aJXw": VideoInfo(id: "rmAcLX7aJXw", title: "Spawn Sacks & Center-Pin Tips", channel: "Addicted Fishing"),
        "RwBtJKHbOsU": VideoInfo(id: "RwBtJKHbOsU", title: "How to Center-Pin for Steelhead", channel: "Adventure Chasing"),
        "JOWSWhJgwoM": VideoInfo(id: "JOWSWhJgwoM", title: "Drift Fishing for Steelhead", channel: "Addicted Fishing"),
        "OZhK53Q_kDE": VideoInfo(id: "OZhK53Q_kDE", title: "Spinner & Spoon Fishing Tips", channel: "Addicted Fishing"),
        "lNid3sV6AHM": VideoInfo(id: "lNid3sV6AHM", title: "How to Fish a Tube Jig (Smallmouth)", channel: "Tailored Tackle"),
        "yekBwnFxiKA": VideoInfo(id: "yekBwnFxiKA", title: "The Tube Fishing Trick", channel: "TacticalBassin"),
        "r9PJZdGniEc": VideoInfo(id: "r9PJZdGniEc", title: "Jig Walleye in Current", channel: "Larry Smith Outdoors"),
        "qQ2oqUc1D_Y": VideoInfo(id: "qQ2oqUc1D_Y", title: "Shore Fishing Walleye Tactics", channel: "Jason Mitchell Outdoors"),
        "sVR_SoQkOAY": VideoInfo(id: "sVR_SoQkOAY", title: "The 3 Top Catfish Rigs", channel: "Catfish Edge"),
        "Ev9s2WvpnI0": VideoInfo(id: "Ev9s2WvpnI0", title: "The Best Catfish Rig", channel: "Fishing Explained"),

        // Added from oEmbed lookup (titles for IDs the web embed shows as generic "Watch")
        "LqQa66veMuM": VideoInfo(id: "LqQa66veMuM", title: "Easiest way to catch Smallmouth Bass. Centerpin Float Fishing. Float, jig head with a minnow.", channel: "Fishing Southern Ontario"),
        "DEvz6ZlSlms": VideoInfo(id: "DEvz6ZlSlms", title: "Centerpin Float Fishing MINNOWS For River Smallmouth!!", channel: "Aaron Nelson"),
        "p-OUz1EeIdU": VideoInfo(id: "p-OUz1EeIdU", title: "Float Fishing for Smallmouth Bass in The Grand River!", channel: "Grand Angling"),
        "NQxTW8le6lw": VideoInfo(id: "NQxTW8le6lw", title: "Centerpin Float Fishing for Smallmouth Bass / Christopher Thuss", channel: "CThuss Fishing"),
        "f5GxwYPPFi0": VideoInfo(id: "f5GxwYPPFi0", title: "Smallmouth bass on centerpin", channel: "FISHBUS Charters"),
        "V6U0-dPF50E": VideoInfo(id: "V6U0-dPF50E", title: "Fly Fish River Smallmouth Bass: Successful fishing tips, techniques, tactics using poppers streamers", channel: "Fish Tails"),
        "oVBDdmXboq4": VideoInfo(id: "oVBDdmXboq4", title: "Big River Fly Fishing for GIANT Smallmouth Bass", channel: "Wild Fly Productions"),
        "E5pFMCBDi6c": VideoInfo(id: "E5pFMCBDi6c", title: "FLY FISHING for BIG River SMALLMOUTH | EPIC Bass Fishing", channel: "Wild Fly Productions"),
        "vwMNmlIoos8": VideoInfo(id: "vwMNmlIoos8", title: "CREEK Fly Fishing for Smallmouth Bass | Top 5 TIPS", channel: "Wild Fly Productions"),
        "L-Lvlcrx3HY": VideoInfo(id: "L-Lvlcrx3HY", title: "Smallmouth Bass Fly Fishing on a Small River With my Boys", channel: "Red's Fly Shop"),
        "INLubW9RfL8": VideoInfo(id: "INLubW9RfL8", title: "Centerpin Jigging For River Walleyes", channel: "Mike Borovic - IT's FRIDAY FITCHES!"),
        "bwrKo4bV-_0": VideoInfo(id: "bwrKo4bV-_0", title: "Centerpin for Walleye? PB!!!!", channel: "Fishing Freshies"),
        "q99pVDQg16g": VideoInfo(id: "q99pVDQg16g", title: "Walleye/Pickerel Fishing Grand River, Ontario. Centerpin Float Fishing #walleye #pickerel", channel: "Fishing Southern Ontario"),
        "WnD2llfdFa4": VideoInfo(id: "WnD2llfdFa4", title: "Center pin fishing for limit of walleye", channel: "lansings finest fishing"),
        "7Kgit5UU-bw": VideoInfo(id: "7Kgit5UU-bw", title: "Bobber Walleyes – The Ultimate Guide (CHEAT CODE for Summer 'Eyes)", channel: "Nick Lindner"),
        "7FcYt3DjcS8": VideoInfo(id: "7FcYt3DjcS8", title: "Walleye Jigging the St Clair River-What to Use and Where to Fish", channel: "Foresight Fishing"),
        "puovlhVEOhM": VideoInfo(id: "puovlhVEOhM", title: "The perfect rod for heavy current vertical jigging.", channel: "TheWalleyeGuys"),
        "tWzWdmgHnu8": VideoInfo(id: "tWzWdmgHnu8", title: "Best Vertical Jigging Setup for Walleye (Rod, Line & Lure)", channel: "DNF Outdoors | The Walleye Guy"),
        "wB6QPtCQoRk": VideoInfo(id: "wB6QPtCQoRk", title: "3 Must-Have Walleye Rods (Jig Fishing)!", channel: "Lindner's Angling Edge"),
        "ovb4Yt_mIJg": VideoInfo(id: "ovb4Yt_mIJg", title: "Line Choices for Jig Fishing Walleye | Mono vs. Braid", channel: "Jason Mitchell Outdoors"),
        "Q0RWBkxn_dY": VideoInfo(id: "Q0RWBkxn_dY", title: "FLY FISHING: HOW TO CATCH WALLEYE ON THE FLY", channel: "Sport Fishing on the Fly"),
        "8_PcB79EPpk": VideoInfo(id: "8_PcB79EPpk", title: "FLY FISHING for Walleye!", channel: "Jay Siemens"),
        "vdNr_GWhuZ0": VideoInfo(id: "vdNr_GWhuZ0", title: "FLIES FOR WALLEYES!! Fly Rigging Wisconsin River Walleyes - SHOP TALK", channel: "Madison Angling"),
        "NZN1OMwVy5k": VideoInfo(id: "NZN1OMwVy5k", title: "Getting Started in Fly Fishing: Walleye on the Fly", channel: "hooked4lifeca"),
        "S1vNRfzkgl8": VideoInfo(id: "S1vNRfzkgl8", title: "Tips and Tricks for Catching River Walleyes With Flies", channel: "DYangBass"),
        "Tzcn8flc3cQ": VideoInfo(id: "Tzcn8flc3cQ", title: "River Fishing for Catfish with Floats - Multi species slam on Mystery River", channel: "Catfish and Carp"),
        "6D79iHbyyAY": VideoInfo(id: "6D79iHbyyAY", title: "Bobber Fishing for Channel Catfish", channel: "Bill & Mikes Angling Adventures"),
        "Te-jpvnw54Q": VideoInfo(id: "Te-jpvnw54Q", title: "How to Rig a Catfish Slip Bobber for Beginners!", channel: "How To KG"),
        "GnUsD-OSjLc": VideoInfo(id: "GnUsD-OSjLc", title: "Slip Bobbers & Chicken for Big Channel Catfish", channel: "Bill & Mikes Angling Adventures"),
        "6TEUws2C9Wc": VideoInfo(id: "6TEUws2C9Wc", title: "Bobber Fishing for Channel Catfish", channel: "Angling Uploaded"),
        "_Ot2XvVEgHA": VideoInfo(id: "_Ot2XvVEgHA", title: "How to Catch Channel Catfish on ANY River System (Riffle, Hole, Run)", channel: "The River Addict"),
        "_vtZSyzqux0": VideoInfo(id: "_vtZSyzqux0", title: "Catfish Rigs, Rods, and Reels || Fishing Gear 101 || Everything You Need To Start Catfishing", channel: "Chris Souders"),
        "iLeI8uxaCHA": VideoInfo(id: "iLeI8uxaCHA", title: "Trophy Catfish Gear Explained! (Rods,reels,Line,Tackle)", channel: "Hagen Grubbs Fishing"),
        "EgbBeCBHang": VideoInfo(id: "EgbBeCBHang", title: "Catfish Rig - What hook, sinker, tackle and leader to use to catch catfish", channel: "Catfish and Carp"),
        "WQAej-2mIg4": VideoInfo(id: "WQAej-2mIg4", title: "Top 3 Catfish Rigs for Beginners!", channel: "How To KG"),
        "kfwh7hBbCHM": VideoInfo(id: "kfwh7hBbCHM", title: "Fly Fishing for Catfish?!?!! - Red River, Manitoba", channel: "Uncut Angling"),
        "0hoD65Zv5sE": VideoInfo(id: "0hoD65Zv5sE", title: "I Tried Everything I Had Catfish on the Fly?", channel: "Alvin Dedeaux"),
        "RIRGG14X8oY": VideoInfo(id: "RIRGG14X8oY", title: "Fly Fishing for Catfish!", channel: "Bama on the Fly"),
        "dzIPgyNgl8I": VideoInfo(id: "dzIPgyNgl8I", title: "My first ever CATFISH ON A FLY ROD, and fly fishing an urban creek for warmwater species!", channel: "Opportunity Fishing"),
        "RF6Wx5BplC4": VideoInfo(id: "RF6Wx5BplC4", title: "Catfish Fishing with a Fly Rod (The ULTIMATE Fly)", channel: "Manitoba Fishing Adventures")
    ]

    // MARK: - Lookup with fallback

    static func info(for id: String) -> VideoInfo {
        labels[id] ?? VideoInfo(id: id, title: "Watch on YouTube", channel: "YouTube")
    }
}
