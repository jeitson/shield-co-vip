// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listed_numbers_dao.dart';

// ignore_for_file: type=lint
mixin _$ListedNumbersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ListedNumbersTableTable get listedNumbersTable =>
      attachedDatabase.listedNumbersTable;
  ListedNumbersDaoManager get managers => ListedNumbersDaoManager(this);
}

class ListedNumbersDaoManager {
  final _$ListedNumbersDaoMixin _db;
  ListedNumbersDaoManager(this._db);
  $$ListedNumbersTableTableTableManager get listedNumbersTable =>
      $$ListedNumbersTableTableTableManager(
        _db.attachedDatabase,
        _db.listedNumbersTable,
      );
}
