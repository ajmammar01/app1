import SwiftUI
import UIKit
import XCTest

/// Proves the widget's view actually renders the verse from the App Group,
/// by writing the same keys lib/widget_bridge.dart writes via home_widget,
/// then rendering the real VerseWidgetEntryView (shared with the VerseWidget
/// extension target, see ios/VerseWidget/VerseWidgetEntryView.swift) to a
/// PNG. RunnerTests is a unit-test bundle hosted inside Runner.app (see
/// TEST_HOST in project.pbxproj), so it runs with Runner's App Group
/// entitlement — no separate entitlement needed for this target.
final class VerseWidgetSnapshotTests: XCTestCase {
    private let appGroupId = "group.com.example.quranApp"

    @MainActor
    func testWidgetRendersVerseFromAppGroup() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("ImageRenderer requires iOS 16+")
        }

        let defaults = try XCTUnwrap(
            UserDefaults(suiteName: appGroupId),
            "Could not open App Group \(appGroupId) — check the entitlements on Runner/RunnerTests"
        )
        defaults.set("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", forKey: "arabicText")
        defaults.set("Bismillahir Rahmanir Raheem", forKey: "transliteration")

        let verse = VerseData.loadFromAppGroup(appGroupId)
        XCTAssertEqual(verse.arabicText, "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
        XCTAssertEqual(verse.transliteration, "Bismillahir Rahmanir Raheem")

        let view = VerseWidgetEntryView(verse: verse)
            .frame(width: 170, height: 170)
            .background(Color.white)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3

        let image = try XCTUnwrap(renderer.uiImage, "Failed to render VerseWidgetEntryView")
        let pngData = try XCTUnwrap(image.pngData(), "Failed to encode rendered view as PNG")

        // /tmp is a plain, unsandboxed path on the Simulator host (Simulator
        // apps aren't sandboxed the way on-device apps are), so the CI
        // workflow can pick this file up directly from the macOS runner
        // after the test finishes.
        let outputURL = URL(fileURLWithPath: "/tmp/verse_widget_snapshot.png")
        try pngData.write(to: outputURL)
        print("VERSE_WIDGET_SNAPSHOT_PATH=\(outputURL.path)")
    }
}
