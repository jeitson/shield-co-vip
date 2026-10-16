// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_hashes_dao.dart';

// ignore_for_file: type=lint
mixin _$PhoneHashesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PhoneHashesTableTable get phoneHashesTable =>
      attachedDatabase.phoneHashesTable;
  PhoneHashesDaoManager get managers => PhoneHashesDaoManager(this);
}

class PhoneHashesDaoManager {
  final _$PhoneHashesDaoMixin _db;
  PhoneHashesDaoManager(this._db);
  $$PhoneHashesTableTableTableManager get phoneHashesTable =>
      $$PhoneHashesTableTableTableManager(
        _db.attachedDatabase,
        _db.phoneHashesTable,
      );
}
