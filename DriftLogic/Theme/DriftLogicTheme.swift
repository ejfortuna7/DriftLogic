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
                Text("read the water · rig the drift")
                    .font(.caption.weight(.medium))
                    .tracking(0.6)
                    .textCase(.uppercase)
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
            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
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
