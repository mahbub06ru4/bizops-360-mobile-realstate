import '../../core/error/result.dart';
import '../../domain/entities/traveller.dart';
import '../../domain/repositories/traveller_repository.dart';
import '../datasources/traveller_remote_datasource.dart';
import '../models/travel_mappers.dart';
import 'remote_guard.dart';

/// HTTP-backed [TravellerRepository] — `GET /travellers`, `GET /travellers/{id}`.
class TravellerRepositoryImpl implements TravellerRepository {
  TravellerRepositoryImpl(this._remote);

  final TravellerRemoteDataSource _remote;

  @override
  Future<Result<List<Traveller>>> travellers() {
    return guardRequest(
      () async =>
          (await _remote.list()).map(travellerFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<Traveller>> byId(String id) {
    return guardRequest(() async => travellerFromJson(await _remote.byId(id)));
  }

  @override
  Future<Result<List<TravelHistoryEntry>>> history(String id) {
    // No dedicated traveller-history endpoint yet; the detail screen tolerates
    // an empty timeline. Wire to the real endpoint when it lands.
    return Future.value(const Result.ok(<TravelHistoryEntry>[]));
  }

  @override
  Future<Result<Traveller>> create({
    required String name,
    String? nationality,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'full_name': name,
        if (nationality != null && nationality.isNotEmpty)
          'nationality': nationality,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (passportNumber != null && passportNumber.isNotEmpty)
          'passport_number': passportNumber,
        if (passportExpiry != null)
          'passport_expiry': passportExpiry.toIso8601String().split('T').first,
      };
      return travellerFromJson(await _remote.create(body));
    });
  }
}
