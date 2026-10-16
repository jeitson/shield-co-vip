// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_dao.dart';

// ignore_for_file: type=lint
mixin _$EventsDaoMixin on DatabaseAccessor<AppDatabase> {
  $InterceptedEventsTableTable get interceptedEventsTable =>
      attachedDatabase.interceptedEventsTable;
  EventsDaoManager get managers => EventsDaoManager(this);
}

class EventsDaoManager {
  final _$EventsDaoMixin _db;
  EventsDaoManager(this._db);
  $$InterceptedEventsTableTableTableManager get interceptedEventsTable =>
      $$InterceptedEventsTableTableTableManager(
        _db.attachedDatabase,
        _db.interceptedEventsTable,
      );
}
