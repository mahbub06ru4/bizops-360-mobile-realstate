import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the real-estate endpoints (`industry:real_estate`
/// gated), following the same `/api/v1`-relative, envelope-returning
/// convention every other data source in this app uses.
///
/// Endpoint shapes match `app/Modules/Industry/RealEstate/Routes/api.php` in
/// `bizops360-api` exactly:
///   GET/POST   /projects
///   GET/PUT    /projects/{id}
///   POST       /projects/{id}/submit
///   POST       /projects/{id}/buildings
///   POST       /buildings/{buildingId}/units        (not nested under project)
///   POST       /projects/{id}/location               (singular)
///   POST       /projects/{id}/amenities
///   POST       /projects/{id}/pricing                (POST, not PUT)
///   POST       /projects/{id}/payment-plans
///   POST       /units/{unitId}/media                 (not nested under project)
///   POST       /units/{unitId}/prices
class RealEstateRemoteDataSource {
  RealEstateRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/projects',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/projects/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/projects/$id',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> submit(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects/$id/submit',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addBuilding(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects/$projectId/buildings',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addUnit(
    String projectId,
    String buildingId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/buildings/$buildingId/units',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addLocation(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects/$projectId/location',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addAmenity(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects/$projectId/amenities',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> setPricing(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects/$projectId/pricing',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addPaymentPlan(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/projects/$projectId/payment-plans',
      body: body,
    );
    return envelopeObject(res.data);
  }

  /// `url` is already-hosted (picked via `image_picker`, uploaded by a
  /// storage step ahead of this call in the real deployment); Phase 0 sends
  /// it as a plain JSON field rather than multipart, matching how the rest of
  /// this datasource posts JSON bodies.
  Future<Map<String, dynamic>> uploadMedia(
    String projectId,
    String unitId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/units/$unitId/media',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addUnitPrice(
    String unitId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/units/$unitId/prices',
      body: body,
    );
    return envelopeObject(res.data);
  }
}
