import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the Phase 1 sales-pipeline endpoints (`industry:
/// real_estate` gated), following the same `/api/v1`-relative,
/// envelope-returning convention as [RealEstateRemoteDataSource]. Exactly
/// matches `app/Modules/Industry/RealEstate/Routes/api.php` /
/// `.../Http/Controllers/Api/V1/*Controller.php` in `bizops360-api`:
///   GET/POST   /real-estate/leads/{lead}/requirements
///   GET        /real-estate/requirements/{id}                (embeds `matches`)
///   POST       /real-estate/requirements/{id}/match
///   GET        /real-estate/site-visits                       (tenant-wide)
///   GET/POST   /real-estate/leads/{lead}/site-visits
///   GET        /real-estate/site-visits/{id}
///   POST       /real-estate/site-visits/{id}/complete
///   POST       /real-estate/site-visits/{id}/cancel
///   GET        /real-estate/offers                             (tenant-wide)
///   GET/POST   /real-estate/leads/{lead}/offers
///   GET        /real-estate/offers/{id}                        (embeds `counter_offers`)
///   POST       /real-estate/offers/{id}/counter
///   POST       /real-estate/offers/{id}/accept
///   POST       /real-estate/offers/{id}/reject
///   POST       /real-estate/offers/{id}/reserve                (creates the booking)
///   GET        /real-estate/real-estate-bookings               (tenant-wide)
///   GET        /real-estate/real-estate-bookings/{id}          (embeds `installment_plan`)
///   POST       /real-estate/real-estate-bookings/{id}/confirm
///   POST       /real-estate/real-estate-bookings/{id}/cancel
///   POST       /real-estate/real-estate-bookings/{id}/installment-plan
///   GET        /real-estate/installment-plans/{id}             (embeds `installments`)
///   POST       /real-estate/installments/{id}/generate-invoice
///   POST       /real-estate/installments/{id}/mark-paid
///
/// There is no `/requirements/{id}/matches`, `/offers/{id}/history`,
/// `/real-estate-bookings/{id}/installment-plan` (GET), or
/// `/installment-plans/{id}/installments` route — those shapes are
/// reconstructed by reading the embedded fields off the `show` responses
/// above (see the repository implementations).
class RealEstatePipelineRemoteDataSource {
  RealEstatePipelineRemoteDataSource(this._client);

  final ApiClient _client;

  // Requirements & matching -------------------------------------------------

  Future<List<Map<String, dynamic>>> requirementsForLead(String leadId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/leads/$leadId/requirements',
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> createRequirement(
    String leadId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/leads/$leadId/requirements',
      body: body,
    );
    return envelopeObject(res.data);
  }

  /// `GET /requirements/{id}` — embeds `lead` and `matches` (each with its
  /// own `unit`).
  Future<Map<String, dynamic>> requirementById(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/requirements/$id',
    );
    return envelopeObject(res.data);
  }

  Future<List<Map<String, dynamic>>> matchRequirement(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/requirements/$id/match',
    );
    return envelopeList(res.data);
  }

  /// No dedicated endpoint — reads `.matches` off the requirement's own show
  /// response.
  Future<List<Map<String, dynamic>>> matchesFor(String requirementId) async {
    final requirement = await requirementById(requirementId);
    final matches = requirement['matches'];
    return matches is List
        ? matches
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList(growable: false)
        : const [];
  }

  // Site visits ---------------------------------------------------------

  Future<List<Map<String, dynamic>>> siteVisits({String? status}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/site-visits',
      query: {'per_page': 100, 'status': ?status},
    );
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> siteVisitsForLead(String leadId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/leads/$leadId/site-visits',
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> scheduleSiteVisit(
    String leadId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/leads/$leadId/site-visits',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> siteVisitById(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/site-visits/$id',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> completeSiteVisit(
    String id, {
    String? feedback,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/site-visits/$id/complete',
      body: {'feedback': ?feedback},
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> cancelSiteVisit(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/site-visits/$id/cancel',
    );
    return envelopeObject(res.data);
  }

  // Offers ----------------------------------------------------------------

  Future<List<Map<String, dynamic>>> offerThreads({
    bool latestPerThread = true,
  }) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/offers',
      query: {'per_page': 100, 'latest_per_thread': latestPerThread},
    );
    return envelopeList(res.data);
  }

  /// `GET /offers/{id}` — embeds `lead`, `unit` and (only here) this offer's
  /// own direct `counter_offers`.
  Future<Map<String, dynamic>> offerById(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/offers/$id',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> makeOffer(
    String leadId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/leads/$leadId/offers',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> counterOffer(
    String offerId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/offers/$offerId/counter',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> acceptOffer(String offerId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/offers/$offerId/accept',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> rejectOffer(String offerId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/offers/$offerId/reject',
    );
    return envelopeObject(res.data);
  }

  // Bookings & installments ------------------------------------------------

  Future<List<Map<String, dynamic>>> bookings({String? status}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/real-estate-bookings',
      query: {'per_page': 100, 'status': ?status},
    );
    return envelopeList(res.data);
  }

  /// `GET /real-estate-bookings/{id}` — embeds `lead`, `unit` and (only
  /// here) `installment_plan` (with its own `installments`).
  Future<Map<String, dynamic>> booking(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/real-estate-bookings/$id',
    );
    return envelopeObject(res.data);
  }

  /// `POST /offers/{offerId}/reserve` — booking creation only ever happens
  /// by reserving an accepted offer; there is no generic booking-create
  /// endpoint. No request body.
  Future<Map<String, dynamic>> reserveBooking(String offerId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/offers/$offerId/reserve',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> confirmBooking(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/real-estate-bookings/$id/confirm',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> cancelBooking(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/real-estate-bookings/$id/cancel',
    );
    return envelopeObject(res.data);
  }

  /// No dedicated endpoint — reads `.installment_plan` off the booking's own
  /// show response (`null` when none has been created yet).
  Future<Map<String, dynamic>?> installmentPlan(String bookingId) async {
    final b = await booking(bookingId);
    final plan = b['installment_plan'];
    return plan is Map ? plan.cast<String, dynamic>() : null;
  }

  /// `GET /installment-plans/{id}` — for refetching a plan (with its
  /// `installments`) directly once its id is known, without going back
  /// through the booking.
  Future<Map<String, dynamic>> installmentPlanById(String planId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/installment-plans/$planId',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> createInstallmentPlan(
    String bookingId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/real-estate-bookings/$bookingId/installment-plan',
      body: body,
    );
    return envelopeObject(res.data);
  }

  /// No dedicated endpoint — reads `.installments` off the plan's own show
  /// response.
  Future<List<Map<String, dynamic>>> installments(String planId) async {
    final plan = await installmentPlanById(planId);
    final list = plan['installments'];
    return list is List
        ? list
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList(growable: false)
        : const [];
  }

  Future<Map<String, dynamic>> generateInvoice(String installmentId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/installments/$installmentId/generate-invoice',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> markInstallmentPaid(String installmentId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/installments/$installmentId/mark-paid',
    );
    return envelopeObject(res.data);
  }
}
