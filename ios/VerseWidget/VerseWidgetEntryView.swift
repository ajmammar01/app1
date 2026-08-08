import SwiftUI

/// The verse text the widget displays, sourced from the App Group shared
/// storage that lib/widget_bridge.dart writes to via home_widget.
///
/// This type has no WidgetKit dependency (SwiftUI only) so it can also be
/// compiled into RunnerTests, letting a plain XCTest render the exact same
/// view the widget extension renders and capture it as a screenshot.
struct VerseData {
    let id: Int
    let arabicText: String
    let transliteration: String
    let isRead: Bool

    static let placeholder = VerseData(
        id: 1,
        arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        transliteration: "Bismillahir Rahmanir Raheem",
        isRead: false
    )

    /// Reads the keys home_widget's iOS plugin writes via
    /// UserDefaults(suiteName: appGroupId).setValue(_, forKey: id) — "id",
    /// "arabicText", "transliteration", and "isRead" — matching
    /// HomeWidget.saveWidgetData calls in lib/widget_bridge.dart. Falls back
    /// to .placeholder if the App Group hasn't been populated yet (e.g.
    /// before the app has run once).
    static func loadFromAppGroup(_ appGroupId: String) -> VerseData {
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return .placeholder
        }
        return VerseData(
            id: defaults.object(forKey: "id") as? Int ?? placeholder.id,
            arabicText: defaults.string(forKey: "arabicText") ?? placeholder.arabicText,
            transliteration: defaults.string(forKey: "transliteration") ?? placeholder.transliteration,
            isRead: defaults.object(forKey: "isRead") as? Bool ?? placeholder.isRead
        )
    }
}

struct VerseWidgetEntryView: View {
    let verse: VerseData

    var body: some View {
        VStack(spacing: 8) {
            // Arabic script is shaped and drawn right-to-left automatically by
            // Text/CoreText, but the *paragraph* alignment for wrapped lines
            // still follows the ambient (left-to-right) layout direction
            // unless told otherwise — hence the explicit overrides below.
            Text(verse.arabicText)
                .font(.title3)
                .multilineTextAlignment(.trailing)
                .environment(\.layoutDirection, .rightToLeft)

            Text(verse.transliteration)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Read: \(verse.isRead)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
