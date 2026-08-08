import 'dart:io';

import 'package:drift/native.dart';
import 'package:quran_app/database/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:test/test.dart';

/// Writes a database file matching the Stage 1 schema (schemaVersion 1,
/// no `isRead` column) with the Stage 1 hardcoded verse already inserted,
/// so the migration in [AppDatabase] can be exercised against it.
void _createStageOneDatabase(String path) {
  final raw = sqlite3.sqlite3.open(path);
  raw.execute('''
    CREATE TABLE verses (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      surah_number INTEGER NOT NULL,
      ayah_start INTEGER NOT NULL,
      ayah_end INTEGER NOT NULL,
      arabic_text TEXT NOT NULL,
      transliteration TEXT NOT NULL
    );
  ''');
  raw.execute(
    'INSERT INTO verses '
    '(surah_number, ayah_start, ayah_end, arabic_text, transliteration) '
    'VALUES (?, ?, ?, ?, ?)',
    [
      1,
      1,
      1,
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'Bismillahir Rahmanir Raheem',
    ],
  );
  raw.execute('PRAGMA user_version = 1');
  raw.dispose();
}

void main() {
  test('migrates from schema v1 to v2, preserving the existing row', () async {
    final dbFile = File(
      '${Directory.systemTemp.path}/'
      'migration_test_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    _createStageOneDatabase(dbFile.path);

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(() async {
      await db.close();
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    });

    final verse = await db.select(db.verses).getSingle();

    expect(verse.surahNumber, 1);
    expect(verse.ayahStart, 1);
    expect(verse.ayahEnd, 1);
    expect(verse.arabicText, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
    expect(verse.transliteration, 'Bismillahir Rahmanir Raheem');
    expect(verse.isRead, false);

    await db.setIsRead(verse.id, true);
    final isReadAfterToggle = await db.getIsRead(verse.id);

    expect(isReadAfterToggle, true);
  });
}
