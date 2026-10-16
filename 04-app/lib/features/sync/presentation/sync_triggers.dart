import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/sync/presentation/sync_controller.dart';

/// Proveedor de conectividad (para el disparo oportunista al recuperar red).
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

/// Coordina los disparos **oportunistas** del sync (`03-datos` §03.4, R7.2):
///
/// - **Al abrir / autenticarse:** cuando el estado de auth pasa a `authenticated`,
///   dispara una sync (una vez por transición).
/// - **Al recuperar conectividad:** escucha `onConnectivityChanged`; al volver a
///   tener red (y con sesión), dispara una sync. El `SyncController`/repositorio
///   de-duplica si ya hay una en curso.
///
/// Es un provider "vivo": se mantiene mientras la app corre. Se activa
/// observándolo una vez desde el arranque (ver [keepSyncTriggersAlive]).
final syncTriggersProvider = Provider<void>((ref) {
  // 1) Disparo al autenticarse.
  ref.listen<AuthStatus>(authStatusProvider, (previous, next) {
    if (next == AuthStatus.authenticated &&
        previous != AuthStatus.authenticated) {
      Future.microtask(() => ref.read(syncControllerProvider.notifier).sync());
    }
  });

  // 2) Disparo al recuperar red.
  final connectivity = ref.watch(connectivityProvider);
  final sub = connectivity.onConnectivityChanged.listen((results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    final authed = ref.read(authStatusProvider) == AuthStatus.authenticated;
    if (online && authed) {
      ref.read(syncControllerProvider.notifier).sync();
    }
  });
  ref.onDispose(sub.cancel);
});

/// Mantiene activos los disparos oportunistas durante toda la vida de la app.
/// Se observa una vez desde el widget raíz.
void keepSyncTriggersAlive(WidgetRef ref) => ref.watch(syncTriggersProvider);
