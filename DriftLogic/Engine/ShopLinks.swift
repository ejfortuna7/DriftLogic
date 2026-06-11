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
        let b = cleanedQuery(pickName)
        return URL(string: "https://www.amazon.com/s?k=" + encodeURIComponent(b + " fishing") + "&tag=rockyriver-20")!
    }

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
