import SwiftUI
import UIKit

enum DriftLogicTheme {
    static let riverTeal = Color(red: 0.18, green: 0.62, blue: 0.72)
    static let salmonPink = Color(red: 0.92, green: 0.28, blue: 0.52)
    static let steelheadNavy = Color(red: 0.06, green: 0.12, blue: 0.24)
    static let sunriseOrange = Color(red: 0.96, green: 0.48, blue: 0.12)
    static let riverMist = Color(red: 0.94, green: 0.96, blue: 0.98)

    static let accent = riverTeal
    static let secondaryAccent = salmonPink

    // MARK: DriftLogic design-system palette (DRIFTLOGIC-HANDOFF.md)

    /// #0f1f3d — app background
    static let navy = Color(red: 15 / 255, green: 31 / 255, blue: 61 / 255)
    /// #2e9eb8 — primary accent
    static let teal = Color(red: 46 / 255, green: 158 / 255, blue: 184 / 255)
    /// #4fbdd4 — highlights
    static let tealLight = Color(red: 79 / 255, green: 189 / 255, blue: 212 / 255)
    /// #eb4785 — secondary accent / "not sure" chip
    static let salmon = Color(red: 235 / 255, green: 71 / 255, blue: 133 / 255)
    /// #f57a1f
    static let orange = Color(red: 245 / 255, green: 122 / 255, blue: 31 / 255)
    /// #f0f5fa — primary text
    static let mist = Color(red: 240 / 255, green: 245 / 255, blue: 250 / 255)
    /// #c4a046 — gold accents (pro tip, fly bullets)
    static let gold = Color(red: 196 / 255, green: 160 / 255, blue: 70 / 255)
    /// #2fb86b — "Go / Build my rig" action green
    static let go = Color(red: 47 / 255, green: 184 / 255, blue: 107 / 255)

    /// Full-screen background: deep navy with a faint teal-to-salmon wash.
    static var screenBackground: some View {
        ZStack {
            navy
            LinearGradient(
                colors: [teal.opacity(0.12), .clear, salmon.opacity(0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }

    static func scriptFont(size: CGFloat) -> Font {
        let candidates = [
            "Snell Roundhand Bold",
            "Snell Roundhand",
            "Bradley Hand Bold",
            "Bradley Hand",
        ]
        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, design: .serif).weight(.semibold).italic()
    }

    @ViewBuilder
    static var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(steelheadNavy.opacity(0.78))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(riverTeal.opacity(0.45), lineWidth: 1)
            }
    }
}

// MARK: - Card styling

struct DriftLogicCard: ViewModifier {
    var accent: Color = DriftLogicTheme.teal

    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.07),
                                Color.white.opacity(0.03),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(accent.opacity(0.28), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            }
    }
}

extension View {
    /// Standard DriftLogic rounded 16pt card on the navy background.
    func driftLogicCard(accent: Color = DriftLogicTheme.teal) -> some View {
        modifier(DriftLogicCard(accent: accent))
    }
}

// MARK: - Haptics

enum DriftLogicHaptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func ready() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Background

struct SteelheadArtBackground: View {
    var body: some View {
        ZStack {
            DriftLogicTheme.steelheadNavy

            Group {
                if let uiImage = UIImage(named: "SteelheadArtAW") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("SteelheadArtAW")
                        .resizable()
                        .scaledToFill()
                }
            }
            .overlay {
                LinearGradient(
                    colors: [
                        DriftLogicTheme.steelheadNavy.opacity(0.35),
                        DriftLogicTheme.steelheadNavy.opacity(0.15),
                        DriftLogicTheme.steelheadNavy.opacity(0.7),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .overlay {
                LinearGradient(
                    colors: [
                        DriftLogicTheme.salmonPink.opacity(0.18),
                        .clear,
                        DriftLogicTheme.riverTeal.opacity(0.2),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct DriftLogicTitleView: View {
    var size: CGFloat = 38
    var showTagline: Bool = true

    var body: some View {
        VStack(spacing: 2) {
            Text("DriftLogic")
                .font(DriftLogicTheme.scriptFont(size: size))
                .foregroundStyle(DriftLogicTheme.riverMist)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
            if showTagline {
                Text("A fly fisherman's rigging guide")
                    .font(.caption.weight(.medium))
                    .tracking(0.4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DriftLogicTheme.riverTeal)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("DriftLogic")
    }
}

extension View {
    func driftLogicFormStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .listSectionSpacing(14)
            .listRowSeparatorTint(DriftLogicTheme.riverTeal.opacity(0.25))
            .background {
                SteelheadArtBackground()
            }
    }

    func driftLogicListRow() -> some View {
        listRowBackground(DriftLogicTheme.cardBackground)
            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
            .foregroundStyle(DriftLogicTheme.riverMist)
    }

    func driftLogicSectionHeader() -> some View {
        font(.subheadline.weight(.semibold))
            .foregroundStyle(DriftLogicTheme.riverTeal)
            .textCase(nil)
    }

    func driftLogicSectionFooter() -> some View {
        font(.footnote)
            .foregroundStyle(DriftLogicTheme.riverMist.opacity(0.75))
    }

    func driftLogicNavigationChrome() -> some View {
        toolbarBackground(DriftLogicTheme.steelheadNavy.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
    }
}
