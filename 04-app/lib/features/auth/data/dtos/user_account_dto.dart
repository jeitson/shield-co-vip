import 'package:shield_app/features/auth/domain/entities/user_account.dart';

/// DTO de cuenta de usuario (serialización ↔ backend / secure storage).
///
/// Mantiene el mapeo JSON fuera del dominio. Las claves espejan el contrato de
/// cuenta (`05-backend-api-metricas`) y el modelo `Usuario` (`00-fundamentos`).
class UserAccountDto {
  const UserAccountDto({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    required this.celular,
    required this.terminosAceptados,
    required this.privacidadAceptada,
  });

  final String id;
  final String correo;
  final String nombre;
  final String apellido;
  final String celular;
  final bool terminosAceptados;
  final bool privacidadAceptada;

  factory UserAccountDto.fromJson(Map<String, dynamic> json) => UserAccountDto(
    id: json['id'] as String,
    correo: json['correo'] as String,
    nombre: json['nombre'] as String,
    apellido: json['apellido'] as String,
    celular: json['celular'] as String,
    terminosAceptados: json['terminos_aceptados'] as bool? ?? false,
    privacidadAceptada: json['privacidad_aceptada'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'correo': correo,
    'nombre': nombre,
    'apellido': apellido,
    'celular': celular,
    'terminos_aceptados': terminosAceptados,
    'privacidad_aceptada': privacidadAceptada,
  };

  factory UserAccountDto.fromEntity(UserAccount user) => UserAccountDto(
    id: user.id,
    correo: user.correo,
    nombre: user.nombre,
    apellido: user.apellido,
    celular: user.celular,
    terminosAceptados: user.terminosAceptados,
    privacidadAceptada: user.privacidadAceptada,
  );

  UserAccount toEntity() => UserAccount(
    id: id,
    correo: correo,
    nombre: nombre,
    apellido: apellido,
    celular: celular,
    terminosAceptados: terminosAceptados,
    privacidadAceptada: privacidadAceptada,
  );
}
