import 'package:drift/drift.dart';

part 'database.g.dart';

class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahStart => integer()();
  IntColumn get ayahEnd => integer()();
  TextColumn get arabicText => text()();
  TextColumn get transliteration => text()();
}

@DriftDatabase(tables: [Verses])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
