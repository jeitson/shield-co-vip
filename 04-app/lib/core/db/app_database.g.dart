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

class $InterceptedEventsTableTable extends InterceptedEventsTable
    with TableInfo<$InterceptedEventsTableTable, InterceptedEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterceptedEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threatTitleMeta = const VerificationMeta(
    'threatTitle',
  );
  @override
  late final GeneratedColumn<String> threatTitle = GeneratedColumn<String>(
    'threat_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reputationTagMeta = const VerificationMeta(
    'reputationTag',
  );
  @override
  late final GeneratedColumn<String> reputationTag = GeneratedColumn<String>(
    'reputation_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosisMeta = const VerificationMeta(
    'diagnosis',
  );
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
    'diagnosis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quarantinedContentMeta =
      const VerificationMeta('quarantinedContent');
  @override
  late final GeneratedColumn<String> quarantinedContent =
      GeneratedColumn<String>(
        'quarantined_content',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sender,
    type,
    level,
    timestamp,
    threatTitle,
    category,
    reputationTag,
    diagnosis,
    quarantinedContent,
    detailsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterceptedEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('threat_title')) {
      context.handle(
        _threatTitleMeta,
        threatTitle.isAcceptableOrUnknown(
          data['threat_title']!,
          _threatTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_threatTitleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('reputation_tag')) {
      context.handle(
        _reputationTagMeta,
        reputationTag.isAcceptableOrUnknown(
          data['reputation_tag']!,
          _reputationTagMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reputationTagMeta);
    }
    if (data.containsKey('diagnosis')) {
      context.handle(
        _diagnosisMeta,
        diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta),
      );
    } else if (isInserting) {
      context.missing(_diagnosisMeta);
    }
    if (data.containsKey('quarantined_content')) {
      context.handle(
        _quarantinedContentMeta,
        quarantinedContent.isAcceptableOrUnknown(
          data['quarantined_content']!,
          _quarantinedContentMeta,
        ),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterceptedEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterceptedEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      threatTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}threat_title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      reputationTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reputation_tag'],
      )!,
      diagnosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis'],
      )!,
      quarantinedContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quarantined_content'],
      ),
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      ),
    );
  }

  @override
  $InterceptedEventsTableTable createAlias(String alias) {
    return $InterceptedEventsTableTable(attachedDatabase, alias);
  }
}

class InterceptedEventRow extends DataClass
    implements Insertable<InterceptedEventRow> {
  /// Identificador único del evento (ordenable por tiempo). PK.
  final String id;

  /// Remitente en formato canónico E.164 (RN-04).
  final String sender;

  /// Vector del evento: `call` | `sms` (enum `ContactChannel`).
  final String type;

  /// Severidad: `ALTO` | `MEDIO` | `BAJO` (enum `ThreatLevel`).
  final String level;

  /// Momento del evento (fecha real, RN-04): gobierna el orden descendente y la
  /// ventana "intercepciones de hoy".
  final DateTime timestamp;

  /// Clasificación legible: "Extorsión Carcelaria", "Phishing Bancario SMS"…
  final String threatTitle;

  /// Categoría estructurada (catálogo RN-07, enum `ThreatCategory`); gobierna la
  /// elegibilidad de exportación SIC (RN-CALLS-02). Se guarda el `label`.
  final String category;

  /// Origen/razón de la detección: "VoIP no registrado", "Ley 2300 Aplicada".
  final String reputationTag;

  /// Explicación de por qué se interceptó.
  final String diagnosis;

  /// Texto del SMS aislado; solo para `sms` (`null` en llamadas).
  final String? quarantinedContent;

  /// Metadatos forenses opcionales (ubicación, duración, operador, intentos)
  /// serializados como JSON. Se materializan en `EventDetails` al mapear.
  final String? detailsJson;
  const InterceptedEventRow({
    required this.id,
    required this.sender,
    required this.type,
    required this.level,
    required this.timestamp,
    required this.threatTitle,
    required this.category,
    required this.reputationTag,
    required this.diagnosis,
    this.quarantinedContent,
    this.detailsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender'] = Variable<String>(sender);
    map['type'] = Variable<String>(type);
    map['level'] = Variable<String>(level);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['threat_title'] = Variable<String>(threatTitle);
    map['category'] = Variable<String>(category);
    map['reputation_tag'] = Variable<String>(reputationTag);
    map['diagnosis'] = Variable<String>(diagnosis);
    if (!nullToAbsent || quarantinedContent != null) {
      map['quarantined_content'] = Variable<String>(quarantinedContent);
    }
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    return map;
  }

  InterceptedEventsTableCompanion toCompanion(bool nullToAbsent) {
    return InterceptedEventsTableCompanion(
      id: Value(id),
      sender: Value(sender),
      type: Value(type),
      level: Value(level),
      timestamp: Value(timestamp),
      threatTitle: Value(threatTitle),
      category: Value(category),
      reputationTag: Value(reputationTag),
      diagnosis: Value(diagnosis),
      quarantinedContent: quarantinedContent == null && nullToAbsent
          ? const Value.absent()
          : Value(quarantinedContent),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
    );
  }

  factory InterceptedEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterceptedEventRow(
      id: serializer.fromJson<String>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      type: serializer.fromJson<String>(json['type']),
      level: serializer.fromJson<String>(json['level']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      threatTitle: serializer.fromJson<String>(json['threatTitle']),
      category: serializer.fromJson<String>(json['category']),
      reputationTag: serializer.fromJson<String>(json['reputationTag']),
      diagnosis: serializer.fromJson<String>(json['diagnosis']),
      quarantinedContent: serializer.fromJson<String?>(
        json['quarantinedContent'],
      ),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sender': serializer.toJson<String>(sender),
      'type': serializer.toJson<String>(type),
      'level': serializer.toJson<String>(level),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'threatTitle': serializer.toJson<String>(threatTitle),
      'category': serializer.toJson<String>(category),
      'reputationTag': serializer.toJson<String>(reputationTag),
      'diagnosis': serializer.toJson<String>(diagnosis),
      'quarantinedContent': serializer.toJson<String?>(quarantinedContent),
      'detailsJson': serializer.toJson<String?>(detailsJson),
    };
  }

  InterceptedEventRow copyWith({
    String? id,
    String? sender,
    String? type,
    String? level,
    DateTime? timestamp,
    String? threatTitle,
    String? category,
    String? reputationTag,
    String? diagnosis,
    Value<String?> quarantinedContent = const Value.absent(),
    Value<String?> detailsJson = const Value.absent(),
  }) => InterceptedEventRow(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    type: type ?? this.type,
    level: level ?? this.level,
    timestamp: timestamp ?? this.timestamp,
    threatTitle: threatTitle ?? this.threatTitle,
    category: category ?? this.category,
    reputationTag: reputationTag ?? this.reputationTag,
    diagnosis: diagnosis ?? this.diagnosis,
    quarantinedContent: quarantinedContent.present
        ? quarantinedContent.value
        : this.quarantinedContent,
    detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
  );
  InterceptedEventRow copyWithCompanion(InterceptedEventsTableCompanion data) {
    return InterceptedEventRow(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      type: data.type.present ? data.type.value : this.type,
      level: data.level.present ? data.level.value : this.level,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      threatTitle: data.threatTitle.present
          ? data.threatTitle.value
          : this.threatTitle,
      category: data.category.present ? data.category.value : this.category,
      reputationTag: data.reputationTag.present
          ? data.reputationTag.value
          : this.reputationTag,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      quarantinedContent: data.quarantinedContent.present
          ? data.quarantinedContent.value
          : this.quarantinedContent,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterceptedEventRow(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp, ')
          ..write('threatTitle: $threatTitle, ')
          ..write('category: $category, ')
          ..write('reputationTag: $reputationTag, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('quarantinedContent: $quarantinedContent, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sender,
    type,
    level,
    timestamp,
    threatTitle,
    category,
    reputationTag,
    diagnosis,
    quarantinedContent,
    detailsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterceptedEventRow &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.type == this.type &&
          other.level == this.level &&
          other.timestamp == this.timestamp &&
          other.threatTitle == this.threatTitle &&
          other.category == this.category &&
          other.reputationTag == this.reputationTag &&
          other.diagnosis == this.diagnosis &&
          other.quarantinedContent == this.quarantinedContent &&
          other.detailsJson == this.detailsJson);
}

class InterceptedEventsTableCompanion
    extends UpdateCompanion<InterceptedEventRow> {
  final Value<String> id;
  final Value<String> sender;
  final Value<String> type;
  final Value<String> level;
  final Value<DateTime> timestamp;
  final Value<String> threatTitle;
  final Value<String> category;
  final Value<String> reputationTag;
  final Value<String> diagnosis;
  final Value<String?> quarantinedContent;
  final Value<String?> detailsJson;
  final Value<int> rowid;
  const InterceptedEventsTableCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.type = const Value.absent(),
    this.level = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.threatTitle = const Value.absent(),
    this.category = const Value.absent(),
    this.reputationTag = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.quarantinedContent = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterceptedEventsTableCompanion.insert({
    required String id,
    required String sender,
    required String type,
    required String level,
    required DateTime timestamp,
    required String threatTitle,
    required String category,
    required String reputationTag,
    required String diagnosis,
    this.quarantinedContent = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sender = Value(sender),
       type = Value(type),
       level = Value(level),
       timestamp = Value(timestamp),
       threatTitle = Value(threatTitle),
       category = Value(category),
       reputationTag = Value(reputationTag),
       diagnosis = Value(diagnosis);
  static Insertable<InterceptedEventRow> custom({
    Expression<String>? id,
    Expression<String>? sender,
    Expression<String>? type,
    Expression<String>? level,
    Expression<DateTime>? timestamp,
    Expression<String>? threatTitle,
    Expression<String>? category,
    Expression<String>? reputationTag,
    Expression<String>? diagnosis,
    Expression<String>? quarantinedContent,
    Expression<String>? detailsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (type != null) 'type': type,
      if (level != null) 'level': level,
      if (timestamp != null) 'timestamp': timestamp,
      if (threatTitle != null) 'threat_title': threatTitle,
      if (category != null) 'category': category,
      if (reputationTag != null) 'reputation_tag': reputationTag,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (quarantinedContent != null) 'quarantined_content': quarantinedContent,
      if (detailsJson != null) 'details_json': detailsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterceptedEventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sender,
    Value<String>? type,
    Value<String>? level,
    Value<DateTime>? timestamp,
    Value<String>? threatTitle,
    Value<String>? category,
    Value<String>? reputationTag,
    Value<String>? diagnosis,
    Value<String?>? quarantinedContent,
    Value<String?>? detailsJson,
    Value<int>? rowid,
  }) {
    return InterceptedEventsTableCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      threatTitle: threatTitle ?? this.threatTitle,
      category: category ?? this.category,
      reputationTag: reputationTag ?? this.reputationTag,
      diagnosis: diagnosis ?? this.diagnosis,
      quarantinedContent: quarantinedContent ?? this.quarantinedContent,
      detailsJson: detailsJson ?? this.detailsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (threatTitle.present) {
      map['threat_title'] = Variable<String>(threatTitle.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (reputationTag.present) {
      map['reputation_tag'] = Variable<String>(reputationTag.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (quarantinedContent.present) {
      map['quarantined_content'] = Variable<String>(quarantinedContent.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterceptedEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp, ')
          ..write('threatTitle: $threatTitle, ')
          ..write('category: $category, ')
          ..write('reputationTag: $reputationTag, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('quarantinedContent: $quarantinedContent, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListedNumbersTableTable extends ListedNumbersTable
    with TableInfo<$ListedNumbersTableTable, ListedNumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListedNumbersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<String> numero = GeneratedColumn<String>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listaMeta = const VerificationMeta('lista');
  @override
  late final GeneratedColumn<String> lista = GeneratedColumn<String>(
    'lista',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [numero, lista, origen, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'numeros_listados';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListedNumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('lista')) {
      context.handle(
        _listaMeta,
        lista.isAcceptableOrUnknown(data['lista']!, _listaMeta),
      );
    } else if (isInserting) {
      context.missing(_listaMeta);
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
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
  Set<GeneratedColumn> get $primaryKey => {numero};
  @override
  ListedNumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListedNumberRow(
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero'],
      )!,
      lista: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lista'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ListedNumbersTableTable createAlias(String alias) {
    return $ListedNumbersTableTable(attachedDatabase, alias);
  }
}

class ListedNumberRow extends DataClass implements Insertable<ListedNumberRow> {
  /// Número en formato canónico E.164 (RN-04). PK → unicidad = RN-05.
  final String numero;

  /// Lista a la que pertenece: `confianza` | `negra` (enum `ListKind`).
  final String lista;

  /// Cómo entró: `manual` | `evento` | `simulador` (enum `ListOrigin`).
  final String origen;

  /// Última modificación local (auditoría; no se sincroniza).
  final DateTime updatedAt;
  const ListedNumberRow({
    required this.numero,
    required this.lista,
    required this.origen,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['numero'] = Variable<String>(numero);
    map['lista'] = Variable<String>(lista);
    map['origen'] = Variable<String>(origen);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ListedNumbersTableCompanion toCompanion(bool nullToAbsent) {
    return ListedNumbersTableCompanion(
      numero: Value(numero),
      lista: Value(lista),
      origen: Value(origen),
      updatedAt: Value(updatedAt),
    );
  }

  factory ListedNumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListedNumberRow(
      numero: serializer.fromJson<String>(json['numero']),
      lista: serializer.fromJson<String>(json['lista']),
      origen: serializer.fromJson<String>(json['origen']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'numero': serializer.toJson<String>(numero),
      'lista': serializer.toJson<String>(lista),
      'origen': serializer.toJson<String>(origen),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ListedNumberRow copyWith({
    String? numero,
    String? lista,
    String? origen,
    DateTime? updatedAt,
  }) => ListedNumberRow(
    numero: numero ?? this.numero,
    lista: lista ?? this.lista,
    origen: origen ?? this.origen,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ListedNumberRow copyWithCompanion(ListedNumbersTableCompanion data) {
    return ListedNumberRow(
      numero: data.numero.present ? data.numero.value : this.numero,
      lista: data.lista.present ? data.lista.value : this.lista,
      origen: data.origen.present ? data.origen.value : this.origen,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListedNumberRow(')
          ..write('numero: $numero, ')
          ..write('lista: $lista, ')
          ..write('origen: $origen, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(numero, lista, origen, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListedNumberRow &&
          other.numero == this.numero &&
          other.lista == this.lista &&
          other.origen == this.origen &&
          other.updatedAt == this.updatedAt);
}

class ListedNumbersTableCompanion extends UpdateCompanion<ListedNumberRow> {
  final Value<String> numero;
  final Value<String> lista;
  final Value<String> origen;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ListedNumbersTableCompanion({
    this.numero = const Value.absent(),
    this.lista = const Value.absent(),
    this.origen = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListedNumbersTableCompanion.insert({
    required String numero,
    required String lista,
    required String origen,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : numero = Value(numero),
       lista = Value(lista),
       origen = Value(origen);
  static Insertable<ListedNumberRow> custom({
    Expression<String>? numero,
    Expression<String>? lista,
    Expression<String>? origen,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (numero != null) 'numero': numero,
      if (lista != null) 'lista': lista,
      if (origen != null) 'origen': origen,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListedNumbersTableCompanion copyWith({
    Value<String>? numero,
    Value<String>? lista,
    Value<String>? origen,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ListedNumbersTableCompanion(
      numero: numero ?? this.numero,
      lista: lista ?? this.lista,
      origen: origen ?? this.origen,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (lista.present) {
      map['lista'] = Variable<String>(lista.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListedNumbersTableCompanion(')
          ..write('numero: $numero, ')
          ..write('lista: $lista, ')
          ..write('origen: $origen, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $InterceptedEventsTableTable interceptedEventsTable =
      $InterceptedEventsTableTable(this);
  late final $ListedNumbersTableTable listedNumbersTable =
      $ListedNumbersTableTable(this);
  late final ShieldConfigDao shieldConfigDao = ShieldConfigDao(
    this as AppDatabase,
  );
  late final PhoneHashesDao phoneHashesDao = PhoneHashesDao(
    this as AppDatabase,
  );
  late final EventsDao eventsDao = EventsDao(this as AppDatabase);
  late final ListedNumbersDao listedNumbersDao = ListedNumbersDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shieldConfigTable,
    phoneHashesTable,
    interceptedEventsTable,
    listedNumbersTable,
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
typedef $$InterceptedEventsTableTableCreateCompanionBuilder =
    InterceptedEventsTableCompanion Function({
      required String id,
      required String sender,
      required String type,
      required String level,
      required DateTime timestamp,
      required String threatTitle,
      required String category,
      required String reputationTag,
      required String diagnosis,
      Value<String?> quarantinedContent,
      Value<String?> detailsJson,
      Value<int> rowid,
    });
typedef $$InterceptedEventsTableTableUpdateCompanionBuilder =
    InterceptedEventsTableCompanion Function({
      Value<String> id,
      Value<String> sender,
      Value<String> type,
      Value<String> level,
      Value<DateTime> timestamp,
      Value<String> threatTitle,
      Value<String> category,
      Value<String> reputationTag,
      Value<String> diagnosis,
      Value<String?> quarantinedContent,
      Value<String?> detailsJson,
      Value<int> rowid,
    });

class $$InterceptedEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $InterceptedEventsTableTable> {
  $$InterceptedEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threatTitle => $composableBuilder(
    column: $table.threatTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reputationTag => $composableBuilder(
    column: $table.reputationTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quarantinedContent => $composableBuilder(
    column: $table.quarantinedContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterceptedEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InterceptedEventsTableTable> {
  $$InterceptedEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threatTitle => $composableBuilder(
    column: $table.threatTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reputationTag => $composableBuilder(
    column: $table.reputationTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quarantinedContent => $composableBuilder(
    column: $table.quarantinedContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterceptedEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterceptedEventsTableTable> {
  $$InterceptedEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get threatTitle => $composableBuilder(
    column: $table.threatTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get reputationTag => $composableBuilder(
    column: $table.reputationTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get quarantinedContent => $composableBuilder(
    column: $table.quarantinedContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );
}

class $$InterceptedEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterceptedEventsTableTable,
          InterceptedEventRow,
          $$InterceptedEventsTableTableFilterComposer,
          $$InterceptedEventsTableTableOrderingComposer,
          $$InterceptedEventsTableTableAnnotationComposer,
          $$InterceptedEventsTableTableCreateCompanionBuilder,
          $$InterceptedEventsTableTableUpdateCompanionBuilder,
          (
            InterceptedEventRow,
            BaseReferences<
              _$AppDatabase,
              $InterceptedEventsTableTable,
              InterceptedEventRow
            >,
          ),
          InterceptedEventRow,
          PrefetchHooks Function()
        > {
  $$InterceptedEventsTableTableTableManager(
    _$AppDatabase db,
    $InterceptedEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterceptedEventsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InterceptedEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InterceptedEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> threatTitle = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> reputationTag = const Value.absent(),
                Value<String> diagnosis = const Value.absent(),
                Value<String?> quarantinedContent = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterceptedEventsTableCompanion(
                id: id,
                sender: sender,
                type: type,
                level: level,
                timestamp: timestamp,
                threatTitle: threatTitle,
                category: category,
                reputationTag: reputationTag,
                diagnosis: diagnosis,
                quarantinedContent: quarantinedContent,
                detailsJson: detailsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sender,
                required String type,
                required String level,
                required DateTime timestamp,
                required String threatTitle,
                required String category,
                required String reputationTag,
                required String diagnosis,
                Value<String?> quarantinedContent = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterceptedEventsTableCompanion.insert(
                id: id,
                sender: sender,
                type: type,
                level: level,
                timestamp: timestamp,
                threatTitle: threatTitle,
                category: category,
                reputationTag: reputationTag,
                diagnosis: diagnosis,
                quarantinedContent: quarantinedContent,
                detailsJson: detailsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $InterceptedEventsTableTable,
                    InterceptedEventRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InterceptedEventsTableTable,
                    InterceptedEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterceptedEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterceptedEventsTableTable,
      InterceptedEventRow,
      $$InterceptedEventsTableTableFilterComposer,
      $$InterceptedEventsTableTableOrderingComposer,
      $$InterceptedEventsTableTableAnnotationComposer,
      $$InterceptedEventsTableTableCreateCompanionBuilder,
      $$InterceptedEventsTableTableUpdateCompanionBuilder,
      (
        InterceptedEventRow,
        BaseReferences<
          _$AppDatabase,
          $InterceptedEventsTableTable,
          InterceptedEventRow
        >,
      ),
      InterceptedEventRow,
      PrefetchHooks Function()
    >;
typedef $$ListedNumbersTableTableCreateCompanionBuilder =
    ListedNumbersTableCompanion Function({
      required String numero,
      required String lista,
      required String origen,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ListedNumbersTableTableUpdateCompanionBuilder =
    ListedNumbersTableCompanion Function({
      Value<String> numero,
      Value<String> lista,
      Value<String> origen,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ListedNumbersTableTableFilterComposer
    extends Composer<_$AppDatabase, $ListedNumbersTableTable> {
  $$ListedNumbersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lista => $composableBuilder(
    column: $table.lista,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListedNumbersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ListedNumbersTableTable> {
  $$ListedNumbersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lista => $composableBuilder(
    column: $table.lista,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListedNumbersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListedNumbersTableTable> {
  $$ListedNumbersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get lista =>
      $composableBuilder(column: $table.lista, builder: (column) => column);

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ListedNumbersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListedNumbersTableTable,
          ListedNumberRow,
          $$ListedNumbersTableTableFilterComposer,
          $$ListedNumbersTableTableOrderingComposer,
          $$ListedNumbersTableTableAnnotationComposer,
          $$ListedNumbersTableTableCreateCompanionBuilder,
          $$ListedNumbersTableTableUpdateCompanionBuilder,
          (
            ListedNumberRow,
            BaseReferences<
              _$AppDatabase,
              $ListedNumbersTableTable,
              ListedNumberRow
            >,
          ),
          ListedNumberRow,
          PrefetchHooks Function()
        > {
  $$ListedNumbersTableTableTableManager(
    _$AppDatabase db,
    $ListedNumbersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListedNumbersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListedNumbersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListedNumbersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> numero = const Value.absent(),
                Value<String> lista = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListedNumbersTableCompanion(
                numero: numero,
                lista: lista,
                origen: origen,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String numero,
                required String lista,
                required String origen,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListedNumbersTableCompanion.insert(
                numero: numero,
                lista: lista,
                origen: origen,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ListedNumbersTableTable, ListedNumberRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ListedNumbersTableTable,
                    ListedNumberRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListedNumbersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListedNumbersTableTable,
      ListedNumberRow,
      $$ListedNumbersTableTableFilterComposer,
      $$ListedNumbersTableTableOrderingComposer,
      $$ListedNumbersTableTableAnnotationComposer,
      $$ListedNumbersTableTableCreateCompanionBuilder,
      $$ListedNumbersTableTableUpdateCompanionBuilder,
      (
        ListedNumberRow,
        BaseReferences<
          _$AppDatabase,
          $ListedNumbersTableTable,
          ListedNumberRow
        >,
      ),
      ListedNumberRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShieldConfigTableTableTableManager get shieldConfigTable =>
      $$ShieldConfigTableTableTableManager(_db, _db.shieldConfigTable);
  $$PhoneHashesTableTableTableManager get phoneHashesTable =>
      $$PhoneHashesTableTableTableManager(_db, _db.phoneHashesTable);
  $$InterceptedEventsTableTableTableManager get interceptedEventsTable =>
      $$InterceptedEventsTableTableTableManager(
        _db,
        _db.interceptedEventsTable,
      );
  $$ListedNumbersTableTableTableManager get listedNumbersTable =>
      $$ListedNumbersTableTableTableManager(_db, _db.listedNumbersTable);
}
