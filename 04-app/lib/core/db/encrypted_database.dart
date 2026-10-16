import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Abre la base local **cifrada** con la [dek] del keystore
/// (`02-seguridad` §02.3, DA-07).
///
/// Usa SQLite3MultipleCiphers (bundlado por el hook `sqlite3mc` del pubspec),
/// que implementa el esquema de cifrado de SQLCipher (AES-256). Antes de que
/// drift use la base:
///  1. Verifica que la variante cifrada está activa (`PRAGMA cipher`); si no,
///     **falla explícito** en vez de abrir una base en claro silenciosamente.
///  2. Selecciona el modo de compatibilidad SQLCipher.
///  3. Aplica la clave con `PRAGMA key`.
///
/// La apertura ocurre en un isolate (`createInBackground`) para no bloquear la
/// UI durante el arranque (R5.1).
LazyDatabase openEncryptedDatabase(String dek) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cifrado_cero.db'));

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        _assertCipherAvailable(rawDb);
        // Modo compatible con el esquema SQLCipher (AES-256).
        rawDb.execute("PRAGMA cipher = 'sqlcipher';");
        rawDb.execute("PRAGMA key = '${_escapePragmaValue(dek)}';");
      },
    );
  });
}

/// Comprueba que el binario enlazado es la variante con cifrado (sqlite3mc).
/// El `PRAGMA cipher` no existe en el SQLite estándar, así que una respuesta
/// vacía significa que el hook de cifrado no se aplicó y debemos abortar.
void _assertCipherAvailable(Database db) {
  final result = db.select('PRAGMA cipher;');
  if (result.isEmpty) {
    throw StateError(
      'La base local no tiene soporte de cifrado (sqlite3mc). Revisa el hook '
      '`hooks.user_defines.sqlite3.source: sqlite3mc` en pubspec.yaml. No se '
      'abrirá una base sin cifrar.',
    );
  }
}

/// Escapa comillas simples para incrustar la clave en el `PRAGMA key`.
String _escapePragmaValue(String source) => source.replaceAll("'", "''");
