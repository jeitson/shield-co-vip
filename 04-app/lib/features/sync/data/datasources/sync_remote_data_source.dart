import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/features/sync/data/dtos/sync_delta_dto.dart';
import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';
import 'package:shield_app/features/sync/domain/repositories/pepper_repository.dart';

/// Fuente remota del dataset: habla con las Edge Functions `v1-sync` y
/// `v1-pepper` a través del [ApiClient] (Dio) ya autenticado por el
/// `SupabaseAuthInterceptor`. Devuelve `Result` con los [Failure] del dominio
/// (el `DioErrorMapper` traduce 401/426/red).
class SyncRemoteDataSource {
  SyncRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET v1-sync?since=N[&pepper_version=P]`.
  Future<Result<SyncDelta>> fetchDelta({
    required int since,
    int? pepperVersion,
  }) async {
    final result = await _client.get<Map<String, dynamic>>(
      'v1-sync',
      queryParameters: {'since': since, 'pepper_version': ?pepperVersion},
    );
    return result.map(SyncDeltaDto.fromJson);
  }

  /// `GET v1-pepper`.
  Future<Result<PepperMaterial>> fetchPepper() async {
    final result = await _client.get<Map<String, dynamic>>('v1-pepper');
    return result.map(
      (json) => PepperMaterial(
        pepper: json['pepper'] as String,
        version: (json['pepper_version'] as num?)?.toInt() ?? 1,
      ),
    );
  }
}
