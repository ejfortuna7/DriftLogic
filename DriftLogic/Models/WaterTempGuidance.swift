import Foundation

extension WaterTemp {

  /// Shown at the top of the water-temperature picker—answers “is this outside temp?”
  static let clarificationIntro = """
  Yes — this means water temperature, not the temperature outside.

  The number on your weather app is air temperature. Fish live in the river, lake, or flat, so this setting uses how warm or cold the water is. Picking the same band as the forecast is a common mistake.
  """

  /// Help when the angler only knows outside (air) temperature.
  static let estimatingWaterFromAir = """
  Only know the weather outside? Use these rules of thumb, then choose the closest water band:

  • Tailwater below a dam — water is often much colder than the air; choose one or two bands colder than the forecast.
  • Spring morning — air can warm before the river does; water is usually colder than it feels outside.
  • Shaded mountain stream in summer — water is often several degrees colder than the afternoon air.
  • Wide shallow lake or salt flat in full sun — afternoon water may be close to the air temperature.
  • Several hot days in a row — ponds and backwaters can warm toward the air temp; trout streams may still run cooler.

  A $10 stream thermometer in the run you plan to fish is the most accurate way to set this.
  """

  var fahrenheitRange: String {
    switch self {
    case .frigid: return "Below 42°F (5°C)"
    case .cold: return "42–50°F (5–10°C)"
    case .prime: return "50–64°F (10–18°C)"
    case .warm: return "64–75°F (18–24°C)"
    case .hot: return "Above 75°F (24°C)"
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
