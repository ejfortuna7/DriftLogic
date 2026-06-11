import SwiftUI

@main
struct DriftLogicApp: App {
    init() {
        DriftLogicAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(DriftLogicTheme.tealLight)
                .preferredColorScheme(.dark)
        }
    }
}
