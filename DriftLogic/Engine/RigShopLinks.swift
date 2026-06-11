import Foundation

/// A purchasable option for a rig row — either a single Amazon link or one of
/// the $ / $$ / $$$ price tiers for rod and reel rows.
struct RigShopOption: Identifiable {
    let tier: String      // "$", "$$", "$$$", or "Amazon"
    let hint: String      // e.g. "Budget", "Mid-range", "Premium" (accessibility / tooltip)
    let url: URL
    var id: String { tier + hint }
}

/// Amazon links for the rig table rows (rod / reel / line / leader / tippet /
/// float). Rod and reel get three price points so anglers can buy at their
/// budget; consumables (line, leader, tippet, floats) get a single link.
/// Queries are brand-anchored at each tier so results are real products.
enum RigShopLinks {

    static func options(forRowLabel label: String, method: Method, rowValue: String) -> [RigShopOption] {
        let key = label.lowercased()
        switch method {
        case .fly:
            if key.contains("rod") { return flyRod(rowValue) }
            if key.contains("tippet") { return single("fluorocarbon tippet trout \(tippetSizes(rowValue))") }
            if key.contains("leader") { return single("tapered leaders trout 9 ft") }
        case .spin:
            if key.contains("rod") { return spinRod(rowValue) }
            if key.contains("reel") { return spinReel(rowValue) }
            if key.contains("line") { return single("fluorocarbon fishing line \(poundTest(rowValue, default: 8)) lb") }
        case .pin:
            if key.contains("rod") { return pinRod() }
            if key.contains("reel") { return pinReel() }
            if key.contains("leader") || key.contains("float") {
                return single("steelhead float kit balsa fluorocarbon leader")
            }
        }
        return []
    }

    // MARK: Tier builders

    private static func flyRod(_ value: String) -> [RigShopOption] {
        let wt = rodWeight(value, default: 7)
        return [
            tier("$", "Budget", "fly rod combo 9 ft \(wt) wt"),
            tier("$$", "Mid-range", "Redington fly rod combo \(wt) weight"),
            tier("$$$", "Premium", "Orvis Clearwater fly rod \(wt) weight"),
        ]
    }

    private static func spinRod(_ value: String) -> [RigShopOption] {
        let ft = rodLengthFeet(value, default: 7)
        return [
            tier("$", "Budget", "Ugly Stik GX2 spinning rod \(ft) ft medium"),
            tier("$$", "Mid-range", "Fenwick HMG spinning rod \(ft) ft medium fast"),
            tier("$$$", "Premium", "St Croix Avid spinning rod \(ft) ft"),
        ]
    }

    private static func spinReel(_ value: String) -> [RigShopOption] {
        let size = reelSize(value, default: 2500)
        return [
            tier("$", "Budget", "Pflueger President spinning reel \(size)"),
            tier("$$", "Mid-range", "Daiwa Fuego LT spinning reel \(size)"),
            tier("$$$", "Premium", "Shimano Stradic spinning reel \(size)"),
        ]
    }

    private static func pinRod() -> [RigShopOption] {
        [
            tier("$", "Budget", "float rod 11 ft steelhead"),
            tier("$$", "Mid-range", "Okuma Guide Select float rod"),
            tier("$$$", "Premium", "centerpin float rod 13 ft"),
        ]
    }

    private static func pinReel() -> [RigShopOption] {
        [
            tier("$", "Budget", "Okuma Avenger spinning reel 3000"),
            tier("$$", "Mid-range", "Okuma Sheffield centerpin float reel"),
            tier("$$$", "Premium", "Okuma Aventa centerpin reel"),
        ]
    }

    // MARK: Helpers

    private static func tier(_ symbol: String, _ hint: String, _ query: String) -> RigShopOption {
        RigShopOption(tier: symbol, hint: hint, url: ShopLinks.amazonSearchURL(for: query))
    }

    private static func single(_ query: String) -> [RigShopOption] {
        [RigShopOption(tier: "Amazon", hint: "Shop on Amazon", url: ShopLinks.amazonSearchURL(for: query))]
    }

    private static func firstMatch(_ pattern: String, in s: String) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let m = re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)),
              m.numberOfRanges > 1,
              let r = Range(m.range(at: 1), in: s)
        else { return nil }
        return String(s[r])
    }

    /// "9 ft 7-wt weight-forward…" → 7
    private static func rodWeight(_ s: String, default d: Int) -> Int {
        firstMatch("(\\d+)\\s*-?\\s*(?:wt|weight)", in: s).flatMap(Int.init) ?? d
    }

    /// "8.5–9 ft medium…" → 9 (uses the upper end of a range)
    private static func rodLengthFeet(_ s: String, default d: Int) -> Int {
        if let upper = firstMatch("[\\d.]+\\s*[–-]\\s*([\\d.]+)\\s*ft", in: s), let v = Double(upper) {
            return Int(v.rounded())
        }
        if let only = firstMatch("([\\d.]+)\\s*ft", in: s), let v = Double(only) {
            return Int(v.rounded())
        }
        return d
    }

    /// "2500–3500 spinning…" → 2500
    private static func reelSize(_ s: String, default d: Int) -> Int {
        firstMatch("(\\d{3,4})", in: s).flatMap(Int.init) ?? d
    }

    /// "8–10 lb fluorocarbon…" → 8
    private static func poundTest(_ s: String, default d: Int) -> Int {
        firstMatch("(\\d+)\\s*[–-]?\\s*\\d*\\s*lb", in: s).flatMap(Int.init) ?? d
    }

    /// "2X–3X fluorocarbon" → "2x 3x"
    private static func tippetSizes(_ s: String) -> String {
        guard let re = try? NSRegularExpression(pattern: "(\\d)X", options: [.caseInsensitive]) else { return "3x" }
        let matches = re.matches(in: s, range: NSRange(s.startIndex..., in: s))
        let sizes = matches.compactMap { Range($0.range(at: 1), in: s).map { "\(s[$0])x" } }
        return sizes.isEmpty ? "3x" : sizes.joined(separator: " ")
    }
}
