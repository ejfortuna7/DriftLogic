import SwiftUI

// MARK: - Flow layout (wrapping HStack)

/// Lays out subviews left-to-right, wrapping to a new row when the
/// proposed width is exceeded. Rows are top-aligned.
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    var rowSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            x += size.width
            widestRow = max(widestRow, x)
            x += spacing
            rowHeight = max(rowHeight, size.height)
        }

        let width = proposal.width ?? widestRow
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                proposal: ProposedViewSize(size)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Condition chip grid

/// A wrapping grid of selectable pill chips. Exactly one option (or none)
/// can be selected. Tapping the selected chip deselects it.
struct ConditionChipGrid<Option: Identifiable & Hashable>: View {
    let options: [Option]
    @Binding var selection: Option?
    let title: (Option) -> String
    /// Accent color per option — teal by default; pass salmon for
    /// "Not sure"-style chips (e.g. Hatch.none).
    var accent: (Option) -> Color

    init(
        options: [Option],
        selection: Binding<Option?>,
        title: @escaping (Option) -> String,
        accent: @escaping (Option) -> Color = { _ in DriftLogicTheme.teal }
    ) {
        self.options = options
        self._selection = selection
        self.title = title
        self.accent = accent
    }

    var body: some View {
        FlowLayout(spacing: 10, rowSpacing: 10) {
            ForEach(options) { option in
                chip(for: option)
            }
        }
    }

    private func chip(for option: Option) -> some View {
        let isSelected = selection == option
        let tint = accent(option)

        return Button {
            DriftLogicHaptics.tap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selection = isSelected ? nil : option
            }
        } label: {
            Text(title(option))
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .foregroundStyle(isSelected ? DriftLogicTheme.navy : DriftLogicTheme.mist)
                .background {
                    Capsule(style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [tint, tint.opacity(0.82)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                : AnyShapeStyle(Color.white.opacity(0.06))
                        )
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(
                                    tint.opacity(isSelected ? 0.9 : 0.35),
                                    lineWidth: 1
                                )
                        }
                }
                .shadow(
                    color: isSelected ? tint.opacity(0.35) : .clear,
                    radius: 6, x: 0, y: 3
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Chip grid") {
    struct Demo: View {
        @State private var clarity: WaterClarity? = .clear
        var body: some View {
            ConditionChipGrid(
                options: Array(WaterClarity.allCases),
                selection: $clarity,
                title: \.displayName
            )
            .padding()
            .background(DriftLogicTheme.navy)
        }
    }
    return Demo().preferredColorScheme(.dark)
}
