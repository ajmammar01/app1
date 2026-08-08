import 'package:drift/drift.dart';

part 'database.g.dart';

class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahStart => integer()();
  IntColumn get ayahEnd => integer()();
  TextColumn get arabicText => text()();
  TextColumn get transliteration => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Verses])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(verses, verses.isRead);
          }
        },
      );

  Future<void> setIsRead(int id, bool isRead) {
    return (update(verses)..where((t) => t.id.equals(id))).write(
      VersesCompanion(isRead: Value(isRead)),
    );
  }

  Future<bool> getIsRead(int id) async {
    final verse =
        await (select(verses)..where((t) => t.id.equals(id))).getSingle();
    return verse.isRead;
  }
}
