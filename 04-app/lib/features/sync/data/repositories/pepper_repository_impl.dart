import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:shield_app/features/sync/domain/repositories/pepper_repository.dart';

/// Implementación de [PepperRepository]: keystore-first con fallback a
/// `v1-pepper`. El pepper nunca toca la base local (`02-seguridad` §02.2).
class PepperRepositoryImpl implements PepperRepository {
  PepperRepositoryImpl({required this.remote, required this.store});

  final SyncRemoteDataSource remote;
  final PepperStore store;

  @override
  Future<Result<PepperMaterial>> getOrFetchPepper() async {
    final cached = await store.readPepper();
    final version = await store.readVersion();
    if (cached != null && cached.isNotEmpty && version != null) {
      return Ok(PepperMaterial(pepper: cached, version: version));
    }
    return refreshPepper();
  }

  @override
  Future<Result<PepperMaterial>> refreshPepper() async {
    final result = await remote.fetchPepper();
    return switch (result) {
      Ok(:final value) => await _persist(value),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<PepperMaterial>> _persist(PepperMaterial material) async {
    await store.write(material.pepper, material.version);
    return Ok(material);
  }

  @override
  Future<void> clear() => store.clear();
}
