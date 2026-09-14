import '../../core/error/result.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/real_estate_pipeline_remote_datasource.dart';
import '../models/real_estate_pipeline_mappers.dart';
import 'remote_guard.dart';

class OfferRepositoryImpl implements OfferRepository {
  OfferRepositoryImpl(this._remote);

  final RealEstatePipelineRemoteDataSource _remote;

  @override
  Future<Result<List<Offer>>> latestPerThread() {
    return guardRequest(
      () async => (await _remote.offerThreads())
          .map(offerFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<List<Offer>>> history(String offerId) {
    return guardRequest(() async {
      // There is no separate history endpoint, and `GET /offers/{id}`'s
      // embedded `counter_offers` only ever holds that offer's own direct
      // children — so a chain built from a single `show` call would miss
      // everything before whichever offer id the caller passed in (usually
      // the thread's current head, which by definition has no children
      // yet). Walk `previous_offer_id` backward instead, one `show` call per
      // node, to reconstruct the full thread.
      final chain = <Offer>[];
      final seen = <String>{};
      String? cursor = offerId;
      while (cursor != null && seen.add(cursor)) {
        final node = await _remote.offerById(cursor);
        chain.add(offerFromJson(node));
        cursor = node['previous_offer_id']?.toString();
      }
      return chain.reversed.toList(growable: false);
    });
  }

  @override
  Future<Result<Offer>> makeOffer({
    required String leadId,
    required String leadName,
    required String unitId,
    required num offeredPrice,
    String? unitName,
    String? projectId,
    String? projectTitle,
    OfferParty? offeredBy,
    String? notes,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'unit_id': unitId,
        'offered_price': offeredPrice,
        'offered_by': ?(offeredBy == null ? null : offerPartyToApi[offeredBy]),
        'notes': ?notes,
      };
      return offerFromJson(await _remote.makeOffer(leadId, body));
    });
  }

  @override
  Future<Result<Offer>> counter(
    String offerId, {
    required num offeredPrice,
    OfferParty? offeredBy,
    String? notes,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'offered_price': offeredPrice,
        'offered_by': ?(offeredBy == null ? null : offerPartyToApi[offeredBy]),
        'notes': ?notes,
      };
      return offerFromJson(await _remote.counterOffer(offerId, body));
    });
  }

  @override
  Future<Result<Offer>> getById(String id) {
    return guardRequest(() async => offerFromJson(await _remote.offerById(id)));
  }

  @override
  Future<Result<Offer>> accept(String offerId) {
    return guardRequest(
      () async => offerFromJson(await _remote.acceptOffer(offerId)),
    );
  }

  @override
  Future<Result<Offer>> reject(String offerId) {
    return guardRequest(
      () async => offerFromJson(await _remote.rejectOffer(offerId)),
    );
  }
}
