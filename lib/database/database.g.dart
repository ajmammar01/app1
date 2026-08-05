// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VersesTable extends Verses with TableInfo<$VersesTable, Verse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahStartMeta = const VerificationMeta(
    'ayahStart',
  );
  @override
  late final GeneratedColumn<int> ayahStart = GeneratedColumn<int>(
    'ayah_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahEndMeta = const VerificationMeta(
    'ayahEnd',
  );
  @override
  late final GeneratedColumn<int> ayahEnd = GeneratedColumn<int>(
    'ayah_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicTextMeta = const VerificationMeta(
    'arabicText',
  );
  @override
  late final GeneratedColumn<String> arabicText = GeneratedColumn<String>(
    'arabic_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transliterationMeta = const VerificationMeta(
    'transliteration',
  );
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
    'transliteration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahNumber,
    ayahStart,
    ayahEnd,
    arabicText,
    transliteration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Verse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_start')) {
      context.handle(
        _ayahStartMeta,
        ayahStart.isAcceptableOrUnknown(data['ayah_start']!, _ayahStartMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahStartMeta);
    }
    if (data.containsKey('ayah_end')) {
      context.handle(
        _ayahEndMeta,
        ayahEnd.isAcceptableOrUnknown(data['ayah_end']!, _ayahEndMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahEndMeta);
    }
    if (data.containsKey('arabic_text')) {
      context.handle(
        _arabicTextMeta,
        arabicText.isAcceptableOrUnknown(data['arabic_text']!, _arabicTextMeta),
      );
    } else if (isInserting) {
      context.missing(_arabicTextMeta);
    }
    if (data.containsKey('transliteration')) {
      context.handle(
        _transliterationMeta,
        transliteration.isAcceptableOrUnknown(
          data['transliteration']!,
          _transliterationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transliterationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Verse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Verse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_start'],
      )!,
      ayahEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_end'],
      )!,
      arabicText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_text'],
      )!,
      transliteration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transliteration'],
      )!,
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }
}

class Verse extends DataClass implements Insertable<Verse> {
  final int id;
  final int surahNumber;
  final int ayahStart;
  final int ayahEnd;
  final String arabicText;
  final String transliteration;
  const Verse({
    required this.id,
    required this.surahNumber,
    required this.ayahStart,
    required this.ayahEnd,
    required this.arabicText,
    required this.transliteration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_start'] = Variable<int>(ayahStart);
    map['ayah_end'] = Variable<int>(ayahEnd);
    map['arabic_text'] = Variable<String>(arabicText);
    map['transliteration'] = Variable<String>(transliteration);
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
      id: Value(id),
      surahNumber: Value(surahNumber),
      ayahStart: Value(ayahStart),
      ayahEnd: Value(ayahEnd),
      arabicText: Value(arabicText),
      transliteration: Value(transliteration),
    );
  }

  factory Verse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Verse(
      id: serializer.fromJson<int>(json['id']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahStart: serializer.fromJson<int>(json['ayahStart']),
      ayahEnd: serializer.fromJson<int>(json['ayahEnd']),
      arabicText: serializer.fromJson<String>(json['arabicText']),
      transliteration: serializer.fromJson<String>(json['transliteration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahStart': serializer.toJson<int>(ayahStart),
      'ayahEnd': serializer.toJson<int>(ayahEnd),
      'arabicText': serializer.toJson<String>(arabicText),
      'transliteration': serializer.toJson<String>(transliteration),
    };
  }

  Verse copyWith({
    int? id,
    int? surahNumber,
    int? ayahStart,
    int? ayahEnd,
    String? arabicText,
    String? transliteration,
  }) => Verse(
    id: id ?? this.id,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahStart: ayahStart ?? this.ayahStart,
    ayahEnd: ayahEnd ?? this.ayahEnd,
    arabicText: arabicText ?? this.arabicText,
    transliteration: transliteration ?? this.transliteration,
  );
  Verse copyWithCompanion(VersesCompanion data) {
    return Verse(
      id: data.id.present ? data.id.value : this.id,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahStart: data.ayahStart.present ? data.ayahStart.value : this.ayahStart,
      ayahEnd: data.ayahEnd.present ? data.ayahEnd.value : this.ayahEnd,
      arabicText: data.arabicText.present
          ? data.arabicText.value
          : this.arabicText,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Verse(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahStart: $ayahStart, ')
          ..write('ayahEnd: $ayahEnd, ')
          ..write('arabicText: $arabicText, ')
          ..write('transliteration: $transliteration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surahNumber,
    ayahStart,
    ayahEnd,
    arabicText,
    transliteration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Verse &&
          other.id == this.id &&
          other.surahNumber == this.surahNumber &&
          other.ayahStart == this.ayahStart &&
          other.ayahEnd == this.ayahEnd &&
          other.arabicText == this.arabicText &&
          other.transliteration == this.transliteration);
}

class VersesCompanion extends UpdateCompanion<Verse> {
  final Value<int> id;
  final Value<int> surahNumber;
  final Value<int> ayahStart;
  final Value<int> ayahEnd;
  final Value<String> arabicText;
  final Value<String> transliteration;
  const VersesCompanion({
    this.id = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahStart = const Value.absent(),
    this.ayahEnd = const Value.absent(),
    this.arabicText = const Value.absent(),
    this.transliteration = const Value.absent(),
  });
  VersesCompanion.insert({
    this.id = const Value.absent(),
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String arabicText,
    required String transliteration,
  }) : surahNumber = Value(surahNumber),
       ayahStart = Value(ayahStart),
       ayahEnd = Value(ayahEnd),
       arabicText = Value(arabicText),
       transliteration = Value(transliteration);
  static Insertable<Verse> custom({
    Expression<int>? id,
    Expression<int>? surahNumber,
    Expression<int>? ayahStart,
    Expression<int>? ayahEnd,
    Expression<String>? arabicText,
    Expression<String>? transliteration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahStart != null) 'ayah_start': ayahStart,
      if (ayahEnd != null) 'ayah_end': ayahEnd,
      if (arabicText != null) 'arabic_text': arabicText,
      if (transliteration != null) 'transliteration': transliteration,
    });
  }

  VersesCompanion copyWith({
    Value<int>? id,
    Value<int>? surahNumber,
    Value<int>? ayahStart,
    Value<int>? ayahEnd,
    Value<String>? arabicText,
    Value<String>? transliteration,
  }) {
    return VersesCompanion(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahStart: ayahStart ?? this.ayahStart,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahStart.present) {
      map['ayah_start'] = Variable<int>(ayahStart.value);
    }
    if (ayahEnd.present) {
      map['ayah_end'] = Variable<int>(ayahEnd.value);
    }
    if (arabicText.present) {
      map['arabic_text'] = Variable<String>(arabicText.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahStart: $ayahStart, ')
          ..write('ayahEnd: $ayahEnd, ')
          ..write('arabicText: $arabicText, ')
          ..write('transliteration: $transliteration')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VersesTable verses = $VersesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [verses];
}

typedef $$VersesTableCreateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      required int surahNumber,
      required int ayahStart,
      required int ayahEnd,
      required String arabicText,
      required String transliteration,
    });
typedef $$VersesTableUpdateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      Value<int> surahNumber,
      Value<int> ayahStart,
      Value<int> ayahEnd,
      Value<String> arabicText,
      Value<String> transliteration,
    });

class $$VersesTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahStart => $composableBuilder(
    column: $table.ayahStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahEnd => $composableBuilder(
    column: $table.ayahEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VersesTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahStart => $composableBuilder(
    column: $table.ayahStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahEnd => $composableBuilder(
    column: $table.ayahEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahStart =>
      $composableBuilder(column: $table.ayahStart, builder: (column) => column);

  GeneratedColumn<int> get ayahEnd =>
      $composableBuilder(column: $table.ayahEnd, builder: (column) => column);

  GeneratedColumn<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => column,
  );
}

class $$VersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersesTable,
          Verse,
          $$VersesTableFilterComposer,
          $$VersesTableOrderingComposer,
          $$VersesTableAnnotationComposer,
          $$VersesTableCreateCompanionBuilder,
          $$VersesTableUpdateCompanionBuilder,
          (Verse, BaseReferences<_$AppDatabase, $VersesTable, Verse>),
          Verse,
          PrefetchHooks Function()
        > {
  $$VersesTableTableManager(_$AppDatabase db, $VersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahStart = const Value.absent(),
                Value<int> ayahEnd = const Value.absent(),
                Value<String> arabicText = const Value.absent(),
                Value<String> transliteration = const Value.absent(),
              }) => VersesCompanion(
                id: id,
                surahNumber: surahNumber,
                ayahStart: ayahStart,
                ayahEnd: ayahEnd,
                arabicText: arabicText,
                transliteration: transliteration,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahNumber,
                required int ayahStart,
                required int ayahEnd,
                required String arabicText,
                required String transliteration,
              }) => VersesCompanion.insert(
                id: id,
                surahNumber: surahNumber,
                ayahStart: ayahStart,
                ayahEnd: ayahEnd,
                arabicText: arabicText,
                transliteration: transliteration,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersesTable,
      Verse,
      $$VersesTableFilterComposer,
      $$VersesTableOrderingComposer,
      $$VersesTableAnnotationComposer,
      $$VersesTableCreateCompanionBuilder,
      $$VersesTableUpdateCompanionBuilder,
      (Verse, BaseReferences<_$AppDatabase, $VersesTable, Verse>),
      Verse,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
}
