import Foundation

extension WaterTemp {

  /// Collapsed help when the angler only knows outside (air) temperature.
  static let estimatingWaterFromAir = """
  Tailwater or spring morning — often 1–2 bands colder than the forecast.
  Shaded mountain stream in summer — usually colder than afternoon air.
  Shallow lake or flat in full sun — afternoon water may match air.
  Several hot days — ponds warm up; trout streams often stay cooler.
  Best: stream thermometer in the run you'll fish.
  """

  var fahrenheitRange: String {
    switch self {
    case .frigid: return "<42°F"
    case .cold: return "42–50°F"
    case .prime: return "50–64°F"
    case .warm: return "64–75°F"
    case .hot: return ">75°F"
    }
  }

  /// Trout begin stressing near 68°F; avoid targeting them above that when possible.
  var troutElevatedStress: Bool {
    self == .warm || self == .hot
  }

  var isFrigidOrCold: Bool {
    self == .frigid || self == .cold
  }

  var isPrime: Bool {
    self == .prime
  }

  var isWarmOrHot: Bool {
    self == .warm || self == .hot
  }

  /// Detail screen (includes species label for context).
  func speciesNotes(for species: TargetSpecies) -> String {
    "\(species.displayName): \(rationaleNote(for: species))"
  }

  /// Why This Rig — selected species only, no label prefix.
  func rationaleNote(for species: TargetSpecies) -> String {
    switch species {
    case .trout:
      return troutNotes
    case .steelhead:
      return steelheadNotes
    case .bassPanfish:
      return bassNotes
    case .redfish:
      return redfishNotes
    }
  }

  private var troutNotes: String {
    switch self {
    case .frigid:
      return "Metabolism very low—few takes; fish deep, slow seams with tiny midges (#20–24)."
    case .cold:
      return "Sluggish but catchable—target tailouts with small nymphs and eggs."
    case .prime:
      return "Peak feeding window—nymphs, emergers, and dries all in play."
    case .warm:
      return "Still fishable; above ~68°F minimize fight time and fish early or late."
    case .hot:
      return "Stressful above ~68–72°F—fish only at dawn in cold inflows, or choose another species."
    }
  }

  private var steelheadNotes: String {
    switch self {
    case .frigid:
      return "Near freezing—lethargic in deep, slow pools; precision drifts with eggs and small stones."
    case .cold:
      return "Hold in softer runs—dead-drift eggs and nymphs."
    case .prime:
      return "Most aggressive band (~45–58°F)—swung flies through travel lanes."
    case .warm:
      return "Upper 50s–low 60s—fish faster riffle heads and brighter patterns."
    case .hot:
      return "Activity drops in mid-60s+—fish early with darker flies in shade."
    }
  }

  private var bassNotes: String {
    switch self {
    case .frigid:
      return "Under ~50°F—sluggish; slow retrieves on deep structure."
    case .cold:
      return "Feeding picks up—slow streamers along sunny banks."
    case .prime:
      return "Strong feeding (~55–70°F)—streamers and starting topwater."
    case .warm:
      return "Peak activity—poppers, frogs, and weed-edge ambushes."
    case .hot:
      return "Fish dawn and dusk; go deeper or shaded cover midday."
    }
  }

  private var redfishNotes: String {
    switch self {
    case .frigid:
      return "Below ~60°F—leave skinny flats; shrimp and Clouser in deeper channels."
    case .cold:
      return "Spotty on flats—mud edges and deeper potholes."
    case .prime:
      return "Prime flats band (~70–85°F)—crabs and shrimp on sand and grass."
    case .warm:
      return "Excellent sight-fishing—match crab color to bottom."
    case .hot:
      return "Midday slowdown—morning flood tides and mangrove shade."
    }
  }
}
