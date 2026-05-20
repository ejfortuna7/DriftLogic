import SwiftUI

@main
struct DriftLogicApp: App {
    init() {
        DriftLogicAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            RigRecommendationView()
                .tint(DriftLogicTheme.accent)
        }
    }
}
