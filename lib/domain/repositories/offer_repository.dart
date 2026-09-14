import '../../core/error/result.dart';
import '../entities/offer.dart';

/// Structured offer/negotiation (roadmap §7 — "structured Offer, not chat"):
/// make → counter → accept/reject, with the full history retrievable per
/// lead+unit thread.
abstract interface class OfferRepository {
  /// Every offer thread's latest offer, newest first — one row per
  /// lead+unit negotiation, for the offers list screen.
  Future<Result<List<Offer>>> latestPerThread();

  /// The full negotiation chain for the thread [offerId] belongs to, oldest
  /// first (opening offer → counters → accepted/rejected). Reconstructed by
  /// walking `previous_offer_id` backward from [offerId] — there is no
  /// separate history endpoint.
  Future<Result<List<Offer>>> history(String offerId);

  /// A single offer node by id — used to look up an accepted offer's terms
  /// when reserving a booking from it.
  Future<Result<Offer>> getById(String id);

  /// Opens a new negotiation thread with an opening offer.
  /// [leadName]/[unitName]/[projectId]/[projectTitle] are never sent to the
  /// backend; they are only threaded through so a fake repository can build
  /// a self-consistent [Offer] without a network round trip.
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
  });

  /// Responds to [offerId] with a new counter-offer in the same thread.
  Future<Result<Offer>> counter(
    String offerId, {
    required num offeredPrice,
    OfferParty? offeredBy,
    String? notes,
  });

  Future<Result<Offer>> accept(String offerId);

  Future<Result<Offer>> reject(String offerId);
}
