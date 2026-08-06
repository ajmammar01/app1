\# Project Context for Claude Code



Quran memorization app (Flutter, iOS + Android). Widget-first hook: short verses shown on home/lock screen widgets.



\## Non-negotiable

\- Offline-first. Local drift DB is the source of truth. Full functionality with no network.

\- State management: Riverpod.

\- Keep schemas and code minimal — don't add fields, tables, or dependencies beyond what's explicitly asked for a given stage.

\- Use the latest stable version of packages/SDKs unless told otherwise.



\## Current build approach

Building a walking skeleton first (drift → home\_widget bridge → native widget render on iOS + Android), not full app structure. Work happens one stage at a time on its own git branch; I (the founder) handle all git commands myself — don't run git commands unless explicitly asked.



\## Stack

Flutter (Dart), drift (local DB), home\_widget (widget bridge), adhan\_dart (prayer times, local calc only), Firebase (Auth/Firestore/Analytics), RevenueCat (payments).



\## Progress

\- Stage 1: drift schema (Verses table: id, surahNumber, ayahStart, ayahEnd, arabicText, transliteration) — done.

\- Stage 2: home\_widget bridge, verified round-trip on physical Android device — done.

\- Stage 3 (next): iOS SwiftUI widget via cloud Mac runner + iOS Simulator.



\## Founder context

First app, no coding background, learning as we go — explain reasoning, don't assume prior knowledge. I direct you step by step; don't take initiative beyond the current stage's explicit scope.

