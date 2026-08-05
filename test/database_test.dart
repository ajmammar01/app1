import 'package:drift/native.dart';
import 'package:quran_app/database/database.dart';
import 'package:test/test.dart';

void main() {
  test('inserts a verse and reads it back', () async {
    final db = AppDatabase(NativeDatabase.memory());

    final id = await db.into(db.verses).insert(
          VersesCompanion.insert(
            surahNumber: 1,
            ayahStart: 1,
            ayahEnd: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            transliteration: 'Bismillahir Rahmanir Raheem',
          ),
        );

    final result =
        await (db.select(db.verses)..where((t) => t.id.equals(id)))
            .getSingle();

    expect(result.surahNumber, 1);
    expect(result.ayahStart, 1);
    expect(result.ayahEnd, 1);
    expect(result.arabicText, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
    expect(result.transliteration, 'Bismillahir Rahmanir Raheem');

    await db.close();
  });
}
