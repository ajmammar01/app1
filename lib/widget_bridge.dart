import 'package:drift/native.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quran_app/database/database.dart';

/// Pushes the hardcoded verse from the drift database to native widget
/// storage via home_widget, then immediately reads it back and prints the
/// result so the round trip can be confirmed from the console.
Future<void> syncHardcodedVerseToWidget() async {
  final db = AppDatabase(NativeDatabase.memory());

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
  await db.close();

  await HomeWidget.saveWidgetData<int>('surahNumber', verse.surahNumber);
  await HomeWidget.saveWidgetData<int>('ayahStart', verse.ayahStart);
  await HomeWidget.saveWidgetData<int>('ayahEnd', verse.ayahEnd);
  await HomeWidget.saveWidgetData<String>('arabicText', verse.arabicText);
  await HomeWidget.saveWidgetData<String>(
    'transliteration',
    verse.transliteration,
  );

  final surahNumber = await HomeWidget.getWidgetData<int>('surahNumber');
  final ayahStart = await HomeWidget.getWidgetData<int>('ayahStart');
  final ayahEnd = await HomeWidget.getWidgetData<int>('ayahEnd');
  final arabicText = await HomeWidget.getWidgetData<String>('arabicText');
  final transliteration =
      await HomeWidget.getWidgetData<String>('transliteration');

  // ignore: avoid_print
  print(
    'Widget bridge round-trip: '
    'surahNumber=$surahNumber, ayahStart=$ayahStart, ayahEnd=$ayahEnd, '
    'arabicText=$arabicText, transliteration=$transliteration',
  );
}
