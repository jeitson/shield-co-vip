import 'package:shield_app/core/error/failure.dart';

/// Resultado de una operación: éxito con valor [Ok] o error con [Err].
///
/// Alternativa ligera a `Either` sin dependencias externas (`04-app-flutter`
/// §04.1 menciona Result/Either en `core/error`). Los repositorios y casos de
/// uso devuelven `Result<T>` en vez de lanzar, forzando el manejo explícito
/// del error en la capa de presentación.
sealed class Result<T> {
  const Result();

  /// `true` si es un resultado exitoso.
  bool get isOk => this is Ok<T>;

  /// `true` si es un resultado de error.
  bool get isErr => this is Err<T>;

  /// Transforma el valor de éxito preservando el error.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => Ok(transform(value)),
        Err<T>(:final failure) => Err(failure),
      };

  /// Colapsa el resultado a un único valor manejando ambos casos.
  R fold<R>(
    R Function(T value) onOk,
    R Function(Failure failure) onErr,
  ) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };
}

/// Caso exitoso.
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

/// Caso de error.
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
