// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shield_config_dao.dart';

// ignore_for_file: type=lint
mixin _$ShieldConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShieldConfigTableTable get shieldConfigTable =>
      attachedDatabase.shieldConfigTable;
  ShieldConfigDaoManager get managers => ShieldConfigDaoManager(this);
}

class ShieldConfigDaoManager {
  final _$ShieldConfigDaoMixin _db;
  ShieldConfigDaoManager(this._db);
  $$ShieldConfigTableTableTableManager get shieldConfigTable =>
      $$ShieldConfigTableTableTableManager(
        _db.attachedDatabase,
        _db.shieldConfigTable,
      );
}
