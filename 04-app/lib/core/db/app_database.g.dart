// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShieldConfigTableTable extends ShieldConfigTable
    with TableInfo<$ShieldConfigTableTable, ShieldConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShieldConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _extorsionMeta = const VerificationMeta(
    'extorsion',
  );
  @override
  late final GeneratedColumn<bool> extorsion = GeneratedColumn<bool>(
    'extorsion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("extorsion" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _callcenterMeta = const VerificationMeta(
    'callcenter',
  );
  @override
  late final GeneratedColumn<bool> callcenter = GeneratedColumn<bool>(
    'callcenter',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("callcenter" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _leyMeta = const VerificationMeta('ley');
  @override
  late final GeneratedColumn<bool> ley = GeneratedColumn<bool>(
    'ley',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ley" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    extorsion,
    callcenter,
    ley,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shield_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShieldConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('extorsion')) {
      context.handle(
        _extorsionMeta,
        extorsion.isAcceptableOrUnknown(data['extorsion']!, _extorsionMeta),
      );
    }
    if (data.containsKey('callcenter')) {
      context.handle(
        _callcenterMeta,
        callcenter.isAcceptableOrUnknown(data['callcenter']!, _callcenterMeta),
      );
    }
    if (data.containsKey('ley')) {
      context.handle(
        _leyMeta,
        ley.isAcceptableOrUnknown(data['ley']!, _leyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShieldConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShieldConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      extorsion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}extorsion'],
      )!,
      callcenter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}callcenter'],
      )!,
      ley: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ley'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShieldConfigTableTable createAlias(String alias) {
    return $ShieldConfigTableTable(attachedDatabase, alias);
  }
}

class ShieldConfigRow extends DataClass implements Insertable<ShieldConfigRow> {
  /// Identificador de la fila singleton (siempre 1).
  final int id;

  /// Capa anti-extorsión (crítica).
  final bool extorsion;

  /// Capa anti call center / spam.
  final bool callcenter;

  /// Capa de cumplimiento Ley 2300.
  final bool ley;

  /// Última modificación local (auditoría; no se sincroniza).
  final DateTime updatedAt;
  const ShieldConfigRow({
    required this.id,
    required this.extorsion,
    required this.callcenter,
    required this.ley,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['extorsion'] = Variable<bool>(extorsion);
    map['callcenter'] = Variable<bool>(callcenter);
    map['ley'] = Variable<bool>(ley);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShieldConfigTableCompanion toCompanion(bool nullToAbsent) {
    return ShieldConfigTableCompanion(
      id: Value(id),
      extorsion: Value(extorsion),
      callcenter: Value(callcenter),
      ley: Value(ley),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShieldConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShieldConfigRow(
      id: serializer.fromJson<int>(json['id']),
      extorsion: serializer.fromJson<bool>(json['extorsion']),
      callcenter: serializer.fromJson<bool>(json['callcenter']),
      ley: serializer.fromJson<bool>(json['ley']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'extorsion': serializer.toJson<bool>(extorsion),
      'callcenter': serializer.toJson<bool>(callcenter),
      'ley': serializer.toJson<bool>(ley),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShieldConfigRow copyWith({
    int? id,
    bool? extorsion,
    bool? callcenter,
    bool? ley,
    DateTime? updatedAt,
  }) => ShieldConfigRow(
    id: id ?? this.id,
    extorsion: extorsion ?? this.extorsion,
    callcenter: callcenter ?? this.callcenter,
    ley: ley ?? this.ley,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ShieldConfigRow copyWithCompanion(ShieldConfigTableCompanion data) {
    return ShieldConfigRow(
      id: data.id.present ? data.id.value : this.id,
      extorsion: data.extorsion.present ? data.extorsion.value : this.extorsion,
      callcenter: data.callcenter.present
          ? data.callcenter.value
          : this.callcenter,
      ley: data.ley.present ? data.ley.value : this.ley,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShieldConfigRow(')
          ..write('id: $id, ')
          ..write('extorsion: $extorsion, ')
          ..write('callcenter: $callcenter, ')
          ..write('ley: $ley, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, extorsion, callcenter, ley, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShieldConfigRow &&
          other.id == this.id &&
          other.extorsion == this.extorsion &&
          other.callcenter == this.callcenter &&
          other.ley == this.ley &&
          other.updatedAt == this.updatedAt);
}

class ShieldConfigTableCompanion extends UpdateCompanion<ShieldConfigRow> {
  final Value<int> id;
  final Value<bool> extorsion;
  final Value<bool> callcenter;
  final Value<bool> ley;
  final Value<DateTime> updatedAt;
  const ShieldConfigTableCompanion({
    this.id = const Value.absent(),
    this.extorsion = const Value.absent(),
    this.callcenter = const Value.absent(),
    this.ley = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ShieldConfigTableCompanion.insert({
    this.id = const Value.absent(),
    this.extorsion = const Value.absent(),
    this.callcenter = const Value.absent(),
    this.ley = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ShieldConfigRow> custom({
    Expression<int>? id,
    Expression<bool>? extorsion,
    Expression<bool>? callcenter,
    Expression<bool>? ley,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (extorsion != null) 'extorsion': extorsion,
      if (callcenter != null) 'callcenter': callcenter,
      if (ley != null) 'ley': ley,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ShieldConfigTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? extorsion,
    Value<bool>? callcenter,
    Value<bool>? ley,
    Value<DateTime>? updatedAt,
  }) {
    return ShieldConfigTableCompanion(
      id: id ?? this.id,
      extorsion: extorsion ?? this.extorsion,
      callcenter: callcenter ?? this.callcenter,
      ley: ley ?? this.ley,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (extorsion.present) {
      map['extorsion'] = Variable<bool>(extorsion.value);
    }
    if (callcenter.present) {
      map['callcenter'] = Variable<bool>(callcenter.value);
    }
    if (ley.present) {
      map['ley'] = Variable<bool>(ley.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShieldConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('extorsion: $extorsion, ')
          ..write('callcenter: $callcenter, ')
          ..write('ley: $ley, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PhoneHashesTableTable extends PhoneHashesTable
    with TableInfo<$PhoneHashesTableTable, PhoneHashesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhoneHashesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelMeta = const VerificationMeta('nivel');
  @override
  late final GeneratedColumn<String> nivel = GeneratedColumn<String>(
    'nivel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtVersionMeta = const VerificationMeta(
    'addedAtVersion',
  );
  @override
  late final GeneratedColumn<int> addedAtVersion = GeneratedColumn<int>(
    'added_at_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _removedAtVersionMeta = const VerificationMeta(
    'removedAtVersion',
  );
  @override
  late final GeneratedColumn<int> removedAtVersion = GeneratedColumn<int>(
    'removed_at_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pepperVersionMeta = const VerificationMeta(
    'pepperVersion',
  );
  @override
  late final GeneratedColumn<int> pepperVersion = GeneratedColumn<int>(
    'pepper_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hash,
    categoria,
    nivel,
    addedAtVersion,
    removedAtVersion,
    pepperVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phone_hashes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhoneHashesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('nivel')) {
      context.handle(
        _nivelMeta,
        nivel.isAcceptableOrUnknown(data['nivel']!, _nivelMeta),
      );
    } else if (isInserting) {
      context.missing(_nivelMeta);
    }
    if (data.containsKey('added_at_version')) {
      context.handle(
        _addedAtVersionMeta,
        addedAtVersion.isAcceptableOrUnknown(
          data['added_at_version']!,
          _addedAtVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addedAtVersionMeta);
    }
    if (data.containsKey('removed_at_version')) {
      context.handle(
        _removedAtVersionMeta,
        removedAtVersion.isAcceptableOrUnknown(
          data['removed_at_version']!,
          _removedAtVersionMeta,
        ),
      );
    }
    if (data.containsKey('pepper_version')) {
      context.handle(
        _pepperVersionMeta,
        pepperVersion.isAcceptableOrUnknown(
          data['pepper_version']!,
          _pepperVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pepperVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hash};
  @override
  PhoneHashesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhoneHashesTableData(
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      nivel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel'],
      )!,
      addedAtVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at_version'],
      )!,
      removedAtVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}removed_at_version'],
      ),
      pepperVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pepper_version'],
      )!,
    );
  }

  @override
  $PhoneHashesTableTable createAlias(String alias) {
    return $PhoneHashesTableTable(attachedDatabase, alias);
  }
}

class PhoneHashesTableData extends DataClass
    implements Insertable<PhoneHashesTableData> {
  /// HMAC-SHA256(pepper, número normalizado). Opaco para el cliente. PK.
  final String hash;

  /// Categoría de amenaza (catálogo RN-07).
  final String categoria;

  /// Nivel de severidad: `ALTO` | `MEDIO` | `BAJO`.
  final String nivel;

  /// Versión del dataset en la que entró esta firma.
  final int addedAtVersion;

  /// Versión en la que se dio de baja; `null` = activa (soft delete).
  final int? removedAtVersion;

  /// Versión del pepper con el que se calculó el hash (detecta rotación).
  final int pepperVersion;
  const PhoneHashesTableData({
    required this.hash,
    required this.categoria,
    required this.nivel,
    required this.addedAtVersion,
    this.removedAtVersion,
    required this.pepperVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hash'] = Variable<String>(hash);
    map['categoria'] = Variable<String>(categoria);
    map['nivel'] = Variable<String>(nivel);
    map['added_at_version'] = Variable<int>(addedAtVersion);
    if (!nullToAbsent || removedAtVersion != null) {
      map['removed_at_version'] = Variable<int>(removedAtVersion);
    }
    map['pepper_version'] = Variable<int>(pepperVersion);
    return map;
  }

  PhoneHashesTableCompanion toCompanion(bool nullToAbsent) {
    return PhoneHashesTableCompanion(
      hash: Value(hash),
      categoria: Value(categoria),
      nivel: Value(nivel),
      addedAtVersion: Value(addedAtVersion),
      removedAtVersion: removedAtVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAtVersion),
      pepperVersion: Value(pepperVersion),
    );
  }

  factory PhoneHashesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhoneHashesTableData(
      hash: serializer.fromJson<String>(json['hash']),
      categoria: serializer.fromJson<String>(json['categoria']),
      nivel: serializer.fromJson<String>(json['nivel']),
      addedAtVersion: serializer.fromJson<int>(json['addedAtVersion']),
      removedAtVersion: serializer.fromJson<int?>(json['removedAtVersion']),
      pepperVersion: serializer.fromJson<int>(json['pepperVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hash': serializer.toJson<String>(hash),
      'categoria': serializer.toJson<String>(categoria),
      'nivel': serializer.toJson<String>(nivel),
      'addedAtVersion': serializer.toJson<int>(addedAtVersion),
      'removedAtVersion': serializer.toJson<int?>(removedAtVersion),
      'pepperVersion': serializer.toJson<int>(pepperVersion),
    };
  }

  PhoneHashesTableData copyWith({
    String? hash,
    String? categoria,
    String? nivel,
    int? addedAtVersion,
    Value<int?> removedAtVersion = const Value.absent(),
    int? pepperVersion,
  }) => PhoneHashesTableData(
    hash: hash ?? this.hash,
    categoria: categoria ?? this.categoria,
    nivel: nivel ?? this.nivel,
    addedAtVersion: addedAtVersion ?? this.addedAtVersion,
    removedAtVersion: removedAtVersion.present
        ? removedAtVersion.value
        : this.removedAtVersion,
    pepperVersion: pepperVersion ?? this.pepperVersion,
  );
  PhoneHashesTableData copyWithCompanion(PhoneHashesTableCompanion data) {
    return PhoneHashesTableData(
      hash: data.hash.present ? data.hash.value : this.hash,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      addedAtVersion: data.addedAtVersion.present
          ? data.addedAtVersion.value
          : this.addedAtVersion,
      removedAtVersion: data.removedAtVersion.present
          ? data.removedAtVersion.value
          : this.removedAtVersion,
      pepperVersion: data.pepperVersion.present
          ? data.pepperVersion.value
          : this.pepperVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhoneHashesTableData(')
          ..write('hash: $hash, ')
          ..write('categoria: $categoria, ')
          ..write('nivel: $nivel, ')
          ..write('addedAtVersion: $addedAtVersion, ')
          ..write('removedAtVersion: $removedAtVersion, ')
          ..write('pepperVersion: $pepperVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    hash,
    categoria,
    nivel,
    addedAtVersion,
    removedAtVersion,
    pepperVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhoneHashesTableData &&
          other.hash == this.hash &&
          other.categoria == this.categoria &&
          other.nivel == this.nivel &&
          other.addedAtVersion == this.addedAtVersion &&
          other.removedAtVersion == this.removedAtVersion &&
          other.pepperVersion == this.pepperVersion);
}

class PhoneHashesTableCompanion extends UpdateCompanion<PhoneHashesTableData> {
  final Value<String> hash;
  final Value<String> categoria;
  final Value<String> nivel;
  final Value<int> addedAtVersion;
  final Value<int?> removedAtVersion;
  final Value<int> pepperVersion;
  final Value<int> rowid;
  const PhoneHashesTableCompanion({
    this.hash = const Value.absent(),
    this.categoria = const Value.absent(),
    this.nivel = const Value.absent(),
    this.addedAtVersion = const Value.absent(),
    this.removedAtVersion = const Value.absent(),
    this.pepperVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhoneHashesTableCompanion.insert({
    required String hash,
    required String categoria,
    required String nivel,
    required int addedAtVersion,
    this.removedAtVersion = const Value.absent(),
    required int pepperVersion,
    this.rowid = const Value.absent(),
  }) : hash = Value(hash),
       categoria = Value(categoria),
       nivel = Value(nivel),
       addedAtVersion = Value(addedAtVersion),
       pepperVersion = Value(pepperVersion);
  static Insertable<PhoneHashesTableData> custom({
    Expression<String>? hash,
    Expression<String>? categoria,
    Expression<String>? nivel,
    Expression<int>? addedAtVersion,
    Expression<int>? removedAtVersion,
    Expression<int>? pepperVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hash != null) 'hash': hash,
      if (categoria != null) 'categoria': categoria,
      if (nivel != null) 'nivel': nivel,
      if (addedAtVersion != null) 'added_at_version': addedAtVersion,
      if (removedAtVersion != null) 'removed_at_version': removedAtVersion,
      if (pepperVersion != null) 'pepper_version': pepperVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhoneHashesTableCompanion copyWith({
    Value<String>? hash,
    Value<String>? categoria,
    Value<String>? nivel,
    Value<int>? addedAtVersion,
    Value<int?>? removedAtVersion,
    Value<int>? pepperVersion,
    Value<int>? rowid,
  }) {
    return PhoneHashesTableCompanion(
      hash: hash ?? this.hash,
      categoria: categoria ?? this.categoria,
      nivel: nivel ?? this.nivel,
      addedAtVersion: addedAtVersion ?? this.addedAtVersion,
      removedAtVersion: removedAtVersion ?? this.removedAtVersion,
      pepperVersion: pepperVersion ?? this.pepperVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (nivel.present) {
      map['nivel'] = Variable<String>(nivel.value);
    }
    if (addedAtVersion.present) {
      map['added_at_version'] = Variable<int>(addedAtVersion.value);
    }
    if (removedAtVersion.present) {
      map['removed_at_version'] = Variable<int>(removedAtVersion.value);
    }
    if (pepperVersion.present) {
      map['pepper_version'] = Variable<int>(pepperVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhoneHashesTableCompanion(')
          ..write('hash: $hash, ')
          ..write('categoria: $categoria, ')
          ..write('nivel: $nivel, ')
          ..write('addedAtVersion: $addedAtVersion, ')
          ..write('removedAtVersion: $removedAtVersion, ')
          ..write('pepperVersion: $pepperVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShieldConfigTableTable shieldConfigTable =
      $ShieldConfigTableTable(this);
  late final $PhoneHashesTableTable phoneHashesTable = $PhoneHashesTableTable(
    this,
  );
  late final ShieldConfigDao shieldConfigDao = ShieldConfigDao(
    this as AppDatabase,
  );
  late final PhoneHashesDao phoneHashesDao = PhoneHashesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shieldConfigTable,
    phoneHashesTable,
  ];
}

typedef $$ShieldConfigTableTableCreateCompanionBuilder =
    ShieldConfigTableCompanion Function({
      Value<int> id,
      Value<bool> extorsion,
      Value<bool> callcenter,
      Value<bool> ley,
      Value<DateTime> updatedAt,
    });
typedef $$ShieldConfigTableTableUpdateCompanionBuilder =
    ShieldConfigTableCompanion Function({
      Value<int> id,
      Value<bool> extorsion,
      Value<bool> callcenter,
      Value<bool> ley,
      Value<DateTime> updatedAt,
    });

class $$ShieldConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShieldConfigTableTable> {
  $$ShieldConfigTableTableFilterComposer({
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

  ColumnFilters<bool> get extorsion => $composableBuilder(
    column: $table.extorsion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get callcenter => $composableBuilder(
    column: $table.callcenter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ley => $composableBuilder(
    column: $table.ley,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShieldConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShieldConfigTableTable> {
  $$ShieldConfigTableTableOrderingComposer({
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

  ColumnOrderings<bool> get extorsion => $composableBuilder(
    column: $table.extorsion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get callcenter => $composableBuilder(
    column: $table.callcenter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ley => $composableBuilder(
    column: $table.ley,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShieldConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShieldConfigTableTable> {
  $$ShieldConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get extorsion =>
      $composableBuilder(column: $table.extorsion, builder: (column) => column);

  GeneratedColumn<bool> get callcenter => $composableBuilder(
    column: $table.callcenter,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ley =>
      $composableBuilder(column: $table.ley, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShieldConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShieldConfigTableTable,
          ShieldConfigRow,
          $$ShieldConfigTableTableFilterComposer,
          $$ShieldConfigTableTableOrderingComposer,
          $$ShieldConfigTableTableAnnotationComposer,
          $$ShieldConfigTableTableCreateCompanionBuilder,
          $$ShieldConfigTableTableUpdateCompanionBuilder,
          (
            ShieldConfigRow,
            BaseReferences<
              _$AppDatabase,
              $ShieldConfigTableTable,
              ShieldConfigRow
            >,
          ),
          ShieldConfigRow,
          PrefetchHooks Function()
        > {
  $$ShieldConfigTableTableTableManager(
    _$AppDatabase db,
    $ShieldConfigTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShieldConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShieldConfigTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShieldConfigTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> extorsion = const Value.absent(),
                Value<bool> callcenter = const Value.absent(),
                Value<bool> ley = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ShieldConfigTableCompanion(
                id: id,
                extorsion: extorsion,
                callcenter: callcenter,
                ley: ley,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> extorsion = const Value.absent(),
                Value<bool> callcenter = const Value.absent(),
                Value<bool> ley = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ShieldConfigTableCompanion.insert(
                id: id,
                extorsion: extorsion,
                callcenter: callcenter,
                ley: ley,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShieldConfigTableTable, ShieldConfigRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ShieldConfigTableTable,
                    ShieldConfigRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShieldConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShieldConfigTableTable,
      ShieldConfigRow,
      $$ShieldConfigTableTableFilterComposer,
      $$ShieldConfigTableTableOrderingComposer,
      $$ShieldConfigTableTableAnnotationComposer,
      $$ShieldConfigTableTableCreateCompanionBuilder,
      $$ShieldConfigTableTableUpdateCompanionBuilder,
      (
        ShieldConfigRow,
        BaseReferences<_$AppDatabase, $ShieldConfigTableTable, ShieldConfigRow>,
      ),
      ShieldConfigRow,
      PrefetchHooks Function()
    >;
typedef $$PhoneHashesTableTableCreateCompanionBuilder =
    PhoneHashesTableCompanion Function({
      required String hash,
      required String categoria,
      required String nivel,
      required int addedAtVersion,
      Value<int?> removedAtVersion,
      required int pepperVersion,
      Value<int> rowid,
    });
typedef $$PhoneHashesTableTableUpdateCompanionBuilder =
    PhoneHashesTableCompanion Function({
      Value<String> hash,
      Value<String> categoria,
      Value<String> nivel,
      Value<int> addedAtVersion,
      Value<int?> removedAtVersion,
      Value<int> pepperVersion,
      Value<int> rowid,
    });

class $$PhoneHashesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PhoneHashesTableTable> {
  $$PhoneHashesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAtVersion => $composableBuilder(
    column: $table.addedAtVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get removedAtVersion => $composableBuilder(
    column: $table.removedAtVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pepperVersion => $composableBuilder(
    column: $table.pepperVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhoneHashesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PhoneHashesTableTable> {
  $$PhoneHashesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAtVersion => $composableBuilder(
    column: $table.addedAtVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get removedAtVersion => $composableBuilder(
    column: $table.removedAtVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pepperVersion => $composableBuilder(
    column: $table.pepperVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhoneHashesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhoneHashesTableTable> {
  $$PhoneHashesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get nivel =>
      $composableBuilder(column: $table.nivel, builder: (column) => column);

  GeneratedColumn<int> get addedAtVersion => $composableBuilder(
    column: $table.addedAtVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get removedAtVersion => $composableBuilder(
    column: $table.removedAtVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pepperVersion => $composableBuilder(
    column: $table.pepperVersion,
    builder: (column) => column,
  );
}

class $$PhoneHashesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhoneHashesTableTable,
          PhoneHashesTableData,
          $$PhoneHashesTableTableFilterComposer,
          $$PhoneHashesTableTableOrderingComposer,
          $$PhoneHashesTableTableAnnotationComposer,
          $$PhoneHashesTableTableCreateCompanionBuilder,
          $$PhoneHashesTableTableUpdateCompanionBuilder,
          (
            PhoneHashesTableData,
            BaseReferences<
              _$AppDatabase,
              $PhoneHashesTableTable,
              PhoneHashesTableData
            >,
          ),
          PhoneHashesTableData,
          PrefetchHooks Function()
        > {
  $$PhoneHashesTableTableTableManager(
    _$AppDatabase db,
    $PhoneHashesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhoneHashesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhoneHashesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhoneHashesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hash = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> nivel = const Value.absent(),
                Value<int> addedAtVersion = const Value.absent(),
                Value<int?> removedAtVersion = const Value.absent(),
                Value<int> pepperVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhoneHashesTableCompanion(
                hash: hash,
                categoria: categoria,
                nivel: nivel,
                addedAtVersion: addedAtVersion,
                removedAtVersion: removedAtVersion,
                pepperVersion: pepperVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hash,
                required String categoria,
                required String nivel,
                required int addedAtVersion,
                Value<int?> removedAtVersion = const Value.absent(),
                required int pepperVersion,
                Value<int> rowid = const Value.absent(),
              }) => PhoneHashesTableCompanion.insert(
                hash: hash,
                categoria: categoria,
                nivel: nivel,
                addedAtVersion: addedAtVersion,
                removedAtVersion: removedAtVersion,
                pepperVersion: pepperVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhoneHashesTableTable, PhoneHashesTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PhoneHashesTableTable,
                    PhoneHashesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhoneHashesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhoneHashesTableTable,
      PhoneHashesTableData,
      $$PhoneHashesTableTableFilterComposer,
      $$PhoneHashesTableTableOrderingComposer,
      $$PhoneHashesTableTableAnnotationComposer,
      $$PhoneHashesTableTableCreateCompanionBuilder,
      $$PhoneHashesTableTableUpdateCompanionBuilder,
      (
        PhoneHashesTableData,
        BaseReferences<
          _$AppDatabase,
          $PhoneHashesTableTable,
          PhoneHashesTableData
        >,
      ),
      PhoneHashesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShieldConfigTableTableTableManager get shieldConfigTable =>
      $$ShieldConfigTableTableTableManager(_db, _db.shieldConfigTable);
  $$PhoneHashesTableTableTableManager get phoneHashesTable =>
      $$PhoneHashesTableTableTableManager(_db, _db.phoneHashesTable);
}
