import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/secure/secure_providers.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source_fake.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source_supabase.dart';
import 'package:shield_app/features/auth/data/datasources/auth_session_store.dart';
import 'package:shield_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shield_app/features/auth/domain/usecases/login.dart';
import 'package:shield_app/features/auth/domain/usecases/logout.dart';
import 'package:shield_app/features/auth/domain/usecases/register.dart';
import 'package:shield_app/features/auth/domain/usecases/request_password_reset.dart';
import 'package:shield_app/features/auth/domain/usecases/resend_confirmation.dart';
import 'package:shield_app/features/auth/domain/usecases/restore_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estado de autenticación de alto nivel para el guard de navegación.
enum AuthStatus {
  /// Aún no se ha resuelto el estado inicial (leyendo secure storage).
  unknown,

  /// Hay sesión válida.
  authenticated,

  /// No hay sesión.
  unauthenticated,
}

// --- Inyección de dependencias (data) ---

// `secureStorageProvider` vive ahora en `core/secure/secure_providers.dart`
// (lo comparten auth, la DEK de la base local y el pepper). Se importa arriba.

/// Almacén seguro de la sesión.
final authSessionStoreProvider = Provider<AuthSessionStore>(
  (ref) => AuthSessionStore(ref.watch(secureStorageProvider)),
);

/// Fuente remota de autenticación, elegida por configuración de entorno.
///
/// - Si hay credenciales de Supabase (`AppConfig.hasSupabase`, inyectadas por
///   `--dart-define`), usa la implementación **real** contra Supabase Auth.
/// - Si no (tests, desarrollo offline), cae a la implementación **fake** en
///   memoria. Dominio y presentación no cambian en ningún caso.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return AuthRemoteDataSourceSupabase(Supabase.instance.client.auth);
  }
  return AuthRemoteDataSourceFake();
});

/// Repositorio de autenticación (compone remoto + store + stream de sesión).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    store: ref.watch(authSessionStoreProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

// --- Casos de uso ---

final loginUseCaseProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<Register>(
  (ref) => Register(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

final restoreSessionUseCaseProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

final requestPasswordResetUseCaseProvider = Provider<RequestPasswordReset>(
  (ref) => RequestPasswordReset(ref.watch(authRepositoryProvider)),
);

final resendConfirmationUseCaseProvider = Provider<ResendConfirmation>(
  (ref) => ResendConfirmation(ref.watch(authRepositoryProvider)),
);

// --- Estado de sesión ---

/// Sesión actual observada en vivo.
///
/// Se siembra con el valor del `watchSession()` del repositorio y dispara la
/// restauración inicial desde secure storage al construirse (R3.2/R3.3).
final sessionProvider =
    NotifierProvider<SessionNotifier, AsyncValue<AuthSession?>>(
      SessionNotifier.new,
    );

class SessionNotifier extends Notifier<AsyncValue<AuthSession?>> {
  @override
  AsyncValue<AuthSession?> build() {
    final repo = ref.watch(authRepositoryProvider);

    // Mantener el estado sincronizado con los cambios del repositorio
    // (login, logout, register, revocación).
    final sub = repo.watchSession().listen(
      (session) => state = AsyncData(session),
    );
    ref.onDispose(sub.cancel);

    // Restauración inicial: `loading` → `data(session|null)`.
    _restore();
    return const AsyncLoading();
  }

  Future<void> _restore() async {
    final result = await ref.read(restoreSessionUseCaseProvider).call();
    state = result.fold(
      (session) => AsyncData(session),
      (failure) => AsyncData(null), // sin sesión usable → tratar como no auth
    );
  }

  /// Cierra sesión y limpia el material local.
  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = const AsyncData(null);
  }
}

/// Deriva el [AuthStatus] para el guard del router desde [sessionProvider].
final authStatusProvider = Provider<AuthStatus>((ref) {
  final session = ref.watch(sessionProvider);
  return session.when(
    loading: () => AuthStatus.unknown,
    error: (_, _) => AuthStatus.unauthenticated,
    data: (s) =>
        s != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
  );
});
