\# Architecture.md



Source of decisions: `project-decisions.md` + this chat. This doc turns those decisions into a concrete technical structure to build from.



\---



\## 1. Stack Overview



| Layer | Choice |

|---|---|

| App | Flutter (Dart) |

| Local database | drift |

| Widget bridge | `home\_widget` package |

| Widget UI (native) | SwiftUI (iOS), Glance/Jetpack Compose (Android) |

| Prayer times | `adhan\_dart` (local calculation) |

| Content pipeline | one-time Python script → Quran Foundation API → bundled content DB |

| Backend | Firebase (Auth, Firestore, Analytics) |

| Payments | RevenueCat |



No custom server. No CDN. No live Quran API calls from the app.



\---



\## 2. Project Structure (two separate codebases)



```

quran-content-pipeline/        # Python, never ships, run once/occasionally

&#x20; fetch.py                     # calls Quran Foundation API

&#x20; build\_db.py                  # writes the bundled sqlite content DB

&#x20; output/content.sqlite        # → copied into the Flutter app's assets



quran-app/                     # Flutter, the actual shipped app

&#x20; lib/

&#x20;   data/

&#x20;     local/                  # drift database + DAOs

&#x20;     content/                # read-only access to bundled content.sqlite

&#x20;     sync/                   # Firestore sync logic

&#x20;   domain/                   # models, business logic (streaks, timeline building)

&#x20;   presentation/             # screens, widgets (Flutter UI)

&#x20;   services/

&#x20;     prayer\_times/           # adhan\_dart wrapper

&#x20;     widget\_bridge/          # home\_widget calls

&#x20;     auth/                   # Firebase Auth wrapper

&#x20;     payments/               # RevenueCat wrapper

&#x20;     analytics/              # Firebase Analytics wrapper

&#x20; ios/

&#x20;   QuranWidget/               # SwiftUI widget extension target

&#x20; android/

&#x20;   app/src/main/kotlin/.../widget/   # Glance widget

&#x20; assets/

&#x20;   content.sqlite             # bundled, read-only

```



\---



\## 3. Data Layer



Two databases on-device, kept separate:



\### 3a. Content DB (`content.sqlite`, bundled, read-only)

Built by the Python pipeline, shipped as an app asset, never written to by the app.



Tables:

\- `verses` — id, surah\_number, ayah\_number, text\_arabic\_uthmani, audio\_file\_ref

\- `verse\_translations` — verse\_id, language\_code, transliteration\_text, translation\_text \*(one row per verse per language — covers ar, en, fr, es, nl)\*

\- `curated\_list` — verse\_id, sort\_order (defines the default zero-setup ordering by length/difficulty)

\- `adhkar` — id, type (`sabah`/`masa`), text\_arabic, audio\_file\_ref

\- `adhkar\_translations` — adhkar\_id, language\_code, translation\_text



\### 3b. User DB (drift, read-write, local source of truth)



Tables:

\- `progress` — verse\_id, status (`not\_started`/`accomplished`), accomplished\_at, updated\_at

\- `personal\_list` — verse\_id, sort\_order, updated\_at

\- `streaks` — current\_streak, longest\_streak, last\_activity\_date, updated\_at

\- `badges\_earned` — badge\_id, earned\_at

\- `settings` — language, calculation\_method, madhab, notifications\_enabled, updated\_at



Every table carries `updated\_at` — this is what powers delta sync (Section 5).



\*\*Migration policy:\*\* every schema change ships with a drift migration step. No destructive migrations without an explicit data-preserving path. Test migrations against a populated DB before release, not an empty one.



\---



\## 4. Prayer Times (`adhan\_dart`)



\- Inputs: device coordinates (requested once, cached), calculation method (default: sensible regional guess, user-changeable in Settings), madhab (Hanafi/Shafi toggle, affects Asr).

\- Computed \*\*on-device\*\*, no network call.

\- Recomputed once per day (e.g., on first app open of the day, or via a lightweight background task) to build that day's Adhkar timeline.

\- Output feeds directly into the widget timeline builder (Section 5).



\---



\## 5. Widget Architecture



\### Data contract (written by Flutter, read by native widget via `home\_widget`)

Shared storage keys (App Group on iOS, SharedPreferences on Android):

\- `current\_verse` — today's verse to memorize (arabic text, transliteration, translation, per user's language)

\- `daily\_timeline` — today's precomputed schedule: `\[{state: quran|adhkar\_sabah|adhkar\_masa, start: time, end: time}]`

\- `streak\_count`

\- `widget\_hidden` — bool, set by the "Hide" button



\### Timeline building (runs in Flutter, once per day)

1\. Get today's prayer times from `adhan\_dart`.

2\. Build the day's state schedule: Quran Mode → Adhkar Sabah (Fajr–11am) → Quran Mode → Adhkar Masa (Asr–Maghrib) → Quran Mode.

3\. Write schedule + content to shared storage via `home\_widget`.

4\. Native widget (WidgetKit on iOS, Glance on Android) reads this once per system-triggered refresh and displays whichever state matches current time — no live polling needed (see Section 9 for why this works within iOS's refresh budget).



\### User-initiated actions (Accomplished / Hide)

\- Native widget button → App Intent (iOS) / Glance action (Android) → writes directly to shared storage → immediately triggers `home\_widget` timeline reload (not subject to the passive refresh budget) → next time Flutter app opens, it reads the shared storage delta and reconciles into the user DB (`progress` table).



\### Deep linking

Each widget state links to its matching in-app route:

\- Quran Mode → Today's Verse screen (that specific verse)

\- Adhkar Sabah/Masa → Adhkar page (full list, not just the one shown)



\---



\## 6. Sync (Firebase)



\### What syncs

Only: `progress`, `streaks`, `personal\_list`, `settings` — matches what's listed as user-generated/mutable state. The content DB never syncs (it's static and bundled).



\### Firestore structure

```

users/{userId}/

&#x20; progress/{verseId}        → { status, accomplishedAt, updatedAt }

&#x20; personalList/{verseId}    → { sortOrder, updatedAt }

&#x20; streaks/current           → { currentStreak, longestStreak, lastActivityDate, updatedAt }

&#x20; settings/current          → { language, calculationMethod, madhab, notificationsEnabled, updatedAt }

```



\### Delta sync logic

\- On reconnect: query Firestore for docs with `updatedAt` newer than the last local sync timestamp → merge down.

\- Push: any local row with `updatedAt` newer than the last successful push → send up.

\- \*\*Conflict resolution: last-write-wins\*\*, compared by `updatedAt`. No merge UI, no conflict prompts shown to the user.



\### Auth

Firebase Auth. Anonymous by default (works fully offline, no signup friction — matches the no-upfront-friction onboarding principle). Optional upgrade to Sign in with Apple / Google when the user wants cross-device sync — this is the trigger point where anonymous local data gets attached to a real identity and pushed to Firestore for the first time.



\---



\## 7. Payments (RevenueCat)



\- No free tier — entire app is gated behind the subscription (Section: Monetization in `project-decisions.md`).

\- 14-day trial, no card required upfront: user gets full access immediately on install; RevenueCat entitlement check happens transparently, trial starts without a payment method attached (offering type configured accordingly in App Store Connect / Play Console).

\- Entitlement check happens on app launch (cached locally, revalidated periodically when online — must not block core offline functionality if the check can't reach the network).

\- Engagement check-in notifications at day 3, 7, 10 — implemented as local scheduled notifications, not server-driven (keeps this working even without a backend round-trip).



\---



\## 8. Analytics (Firebase Analytics)



Minimum event set: `app\_opened`, `onboarding\_completed`, `verse\_accomplished`, `trial\_started`, `paywall\_viewed`, `subscription\_started`, `subscription\_cancelled`.



\---



\## 9. Reliability Implementation Notes



\- \*\*Migrations:\*\* drift migration tested against a populated DB copy before every release.

\- \*\*Crash reporting:\*\* Firebase Crashlytics, wired in from the first build, not added later.

\- \*\*Fallback states required for:\*\* location permission denied (prayer times use last-known/default location, clearly flagged in UI, not silently wrong), audio file missing/corrupted (skip gracefully, don't crash), widget shared-storage write failure (retry on next app open, don't lose the pending change).

\- \*\*Widget refresh budget:\*\* confirmed — passive OS refresh (\~40-70/day) governs background polling only; user-initiated taps (Accomplished/Hide) fire immediately via App Intents and are not subject to this budget. Timeline-based scheduling (Section 5) means the daily Adhkar transitions don't depend on live wake-ups at all.

\- \*\*Permissions:\*\* requested contextually (location only when Adhkar/prayer features are first reached, notifications only when trial check-ins are about to matter) — never all upfront during onboarding.



\---



\## 10. Localization



v1 languages: Arabic, English, French, Spanish, Dutch.

\- Content DB: one row per verse per language in `verse\_translations`/`adhkar\_translations` (Section 3a).

\- App UI strings: standard Flutter `intl`/ARB-file localization, same five languages.

\- RTL: Arabic requires full RTL layout support — Flutter's built-in `Directionality` handles this, but every screen needs explicit testing in RTL, not assumed to "just work."



## iOS Widget Data Contract



\- Shared storage: iOS App Group `group.com.example.quranApp` (UserDefaults 

&#x20; suite). Android uses SharedPreferences directly — no App Group equivalent 

&#x20; needed there.

\- Keys written by lib/widget\_bridge.dart via home\_widget, read by the SwiftUI 

&#x20; widget (ios/VerseWidget/VerseWidgetEntryView.swift):

&#x20; - arabicText

&#x20; - transliteration

\- iOS deployment targets: Runner app = 14.0 (chosen for home\_widget/WidgetKit 

&#x20; compatibility while staying broadly device-compatible), VerseWidget 

&#x20; extension = 17.0.

\- iOS widget target (VerseWidget) is generated/maintained via a Ruby script 

&#x20; (ios/add\_widget\_extension.rb, uses the xcodeproj gem) run in CI — not 

&#x20; committed as a static Xcode project state, since there's no local Mac to 

&#x20; edit it manually. Every CI run regenerates the target fresh.

