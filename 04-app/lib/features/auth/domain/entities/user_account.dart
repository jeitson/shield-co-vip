import 'package:equatable/equatable.dart';

/// Cuenta de usuario del dominio.
///
/// Espeja el modelo `Usuario` de `00-fundamentos` §00.2. Representa la identidad
/// de cuenta que el servidor **sí** conoce (correo y propio número), distinta de
/// los datos de terceros que nunca salen del dispositivo (`02-seguridad` §02.1).
class UserAccount extends Equatable {
  const UserAccount({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    required this.celular,
    required this.terminosAceptados,
    required this.privacidadAceptada,
  });

  /// Identificador de la cuenta.
  final String id;

  /// Correo de acceso (normalizado).
  final String correo;

  final String nombre;
  final String apellido;

  /// Celular propio en formato canónico E.164 (`+57XXXXXXXXXX`).
  final String celular;

  /// Consentimiento de T&C (requisito legal de alta, RN-REG-03).
  final bool terminosAceptados;

  /// Consentimiento de la nota de privacidad (RN-01).
  final bool privacidadAceptada;

  /// Nombre completo para encabezados/saludos.
  String get nombreCompleto => '$nombre $apellido'.trim();

  @override
  List<Object?> get props => [
    id,
    correo,
    nombre,
    apellido,
    celular,
    terminosAceptados,
    privacidadAceptada,
  ];
}
