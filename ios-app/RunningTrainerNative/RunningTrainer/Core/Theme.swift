import SwiftUI

// MARK: - Color Palette (matches Flutter/Android reference)

extension Color {
    static let appBackground    = Color(hex: "0A0A0F")
    static let appSurface       = Color(hex: "13131A")
    static let appSurfaceVar    = Color(hex: "1E1E2A")
    static let appPrimary       = Color(hex: "00E5FF")
    static let appSecondary     = Color(hex: "76FF03")
    static let appOnDark        = Color(hex: "E8E8F0")
    static let appTextMuted     = Color(hex: "8888AA")
    static let appErrorRed      = Color(hex: "FF5252")
}

extension Color {
    static func workoutTypeColor(_ type: WorkoutType) -> Color {
        switch type {
        case .easyRun:     return Color(hex: "4CAF50")
        case .longRun:     return Color(hex: "9C27B0")
        case .tempoRun:    return Color(hex: "FF9800")
        case .intervalRun: return Color(hex: "F44336")
        case .crossTrain:  return Color(hex: "2196F3")
        case .rest:        return Color(hex: "607D8B")
        }
    }

    static func insightTypeColor(_ type: InsightType) -> Color {
        switch type {
        case .positive:   return Color(hex: "76FF03")
        case .warning:    return Color(hex: "FF9800")
        case .motivation: return Color(hex: "00E5FF")
        case .info:       return Color(hex: "8888AA")
        }
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Reusable Components

struct SurfaceCard<Content: View>: View {
    var accentBorder: Color?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentBorder ?? Color.appSurfaceVar, lineWidth: accentBorder != nil ? 2 : 1)
        )
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.appBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isEnabled ? Color.appPrimary : Color.appTextMuted)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEnabled)
    }
}

struct SelectionCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    init(title: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appOnDark)
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 14))
                        .foregroundColor(.appTextMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(isSelected ? Color.appPrimary.opacity(0.15) : Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appPrimary : Color.appSurfaceVar, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct InsightChipView: View {
    let insight: CoachingInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(insight.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.insightTypeColor(insight.type))
            Text(insight.body)
                .font(.system(size: 12))
                .foregroundColor(.appTextMuted)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 200, alignment: .leading)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.insightTypeColor(insight.type).opacity(0.4), lineWidth: 1)
        )
    }
}

struct WorkoutTypeBadge: View {
    let type: WorkoutType

    var body: some View {
        Text(type.displayName)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color.workoutTypeColor(type))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.workoutTypeColor(type).opacity(0.15))
            .clipShape(Capsule())
    }
}

struct PlanChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.appPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.appPrimary.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Onboarding progress bar

struct OnboardingProgressBar: View {
    let step: Int
    let total: Int = 5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i < step ? Color.appPrimary : Color.appSurfaceVar)
                    .frame(height: 4)
            }
        }
    }
}
