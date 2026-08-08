import 'package:drift/native.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quran_app/database/database.dart';

/// App Group shared between the Runner app and the VerseWidget extension,
/// matching the group id declared in ios/Runner/Runner.entitlements and
/// ios/VerseWidget/VerseWidget.entitlements. Required on iOS before any
/// saveWidgetData/getWidgetData call; ignored on Android.
const _iosAppGroupId = 'group.com.example.quranApp';

/// Registered receiver name for the Android Glance widget, matching
/// VerseGlanceWidgetReceiver in AndroidManifest.xml.
const _androidWidgetReceiver = 'VerseGlanceWidgetReceiver';

AppDatabase? _db;

/// Kept open for the lifetime of the app process (rather than closed after
/// the initial sync) so a later widget tap can look up and toggle the same
/// in-memory row that was pushed to the widget at startup.
AppDatabase _database() => _db ??= AppDatabase(NativeDatabase.memory());

/// Pushes the hardcoded verse from the drift database to native widget
/// storage via home_widget, then immediately reads it back and prints the
/// result so the round trip can be confirmed from the console.
Future<void> syncHardcodedVerseToWidget() async {
  await HomeWidget.setAppGroupId(_iosAppGroupId);

  final db = _database();

  await db.into(db.verses).insert(
        VersesCompanion.insert(
          surahNumber: 1,
          ayahStart: 1,
          ayahEnd: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          transliteration: 'Bismillahir Rahmanir Raheem',
        ),
      );

  final verse = await db.select(db.verses).getSingle();
  await _pushVerseToWidget(verse);

  // ignore: avoid_print
  print(
    'Widget bridge round-trip: '
    'surahNumber=${verse.surahNumber}, ayahStart=${verse.ayahStart}, '
    'ayahEnd=${verse.ayahEnd}, arabicText=${verse.arabicText}, '
    'transliteration=${verse.transliteration}, isRead=${verse.isRead}',
  );
}

/// Handles a tap on the Android home screen widget: reads the verse id
/// from [uri]'s query parameters, toggles `isRead` for that verse via
/// [AppDatabase.setIsRead], then pushes the new state back to the widget
/// so it visually reflects the change. No-ops if [uri] carries no
/// recognizable verse id (e.g. app launched normally, not via the widget).
Future<void> handleWidgetTap(Uri? uri) async {
  final verseId = int.tryParse(uri?.queryParameters['id'] ?? '');
  if (verseId == null) return;

  final db = _database();
  final verse =
      await (db.select(db.verses)..where((t) => t.id.equals(verseId)))
          .getSingleOrNull();
  if (verse == null) return;

  await db.setIsRead(verseId, !verse.isRead);
  final updated =
      await (db.select(db.verses)..where((t) => t.id.equals(verseId)))
          .getSingle();
  await _pushVerseToWidget(updated);

  // ignore: avoid_print
  print('Widget tap: toggled isRead for verse $verseId to ${updated.isRead}');
}

Future<void> _pushVerseToWidget(Verse verse) async {
  await HomeWidget.saveWidgetData<int>('id', verse.id);
  await HomeWidget.saveWidgetData<int>('surahNumber', verse.surahNumber);
  await HomeWidget.saveWidgetData<int>('ayahStart', verse.ayahStart);
  await HomeWidget.saveWidgetData<int>('ayahEnd', verse.ayahEnd);
  await HomeWidget.saveWidgetData<String>('arabicText', verse.arabicText);
  await HomeWidget.saveWidgetData<String>(
    'transliteration',
    verse.transliteration,
  );
  await HomeWidget.saveWidgetData<bool>('isRead', verse.isRead);
  await HomeWidget.updateWidget(androidName: _androidWidgetReceiver);
}
