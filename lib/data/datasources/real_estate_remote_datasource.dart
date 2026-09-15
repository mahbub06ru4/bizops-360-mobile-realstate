import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the real-estate endpoints (`industry:real_estate`
/// gated), following the same `/api/v1`-relative, envelope-returning
/// convention every other data source in this app uses.
///
/// Endpoint shapes match `app/Modules/Industry/RealEstate/Routes/api.php` in
/// `bizops360-api` exactly — the whole module is namespaced under
/// `/real-estate` (moved there to stop colliding with Operations' own
/// `/projects` resource):
///   GET/POST   /real-estate/projects
///   GET/PUT    /real-estate/projects/{id}
///   POST       /real-estate/projects/{id}/submit
///   POST       /real-estate/projects/{id}/buildings
///   POST       /real-estate/buildings/{buildingId}/units   (not nested under project)
///   POST       /real-estate/projects/{id}/location          (singular)
///   POST       /real-estate/projects/{id}/amenities
///   POST       /real-estate/projects/{id}/pricing           (POST, not PUT)
///   POST       /real-estate/projects/{id}/payment-plans
///   POST       /real-estate/units/{unitId}/media            (not nested under project)
///   POST       /real-estate/units/{unitId}/prices
class RealEstateRemoteDataSource {
  RealEstateRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/projects',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/real-estate/projects/$id',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/real-estate/projects/$id',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> submit(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects/$id/submit',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addBuilding(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects/$projectId/buildings',
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
      '/real-estate/buildings/$buildingId/units',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addLocation(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects/$projectId/location',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addAmenity(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects/$projectId/amenities',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> setPricing(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects/$projectId/pricing',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addPaymentPlan(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/projects/$projectId/payment-plans',
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
      '/real-estate/units/$unitId/media',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> addUnitPrice(
    String unitId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/real-estate/units/$unitId/prices',
      body: body,
    );
    return envelopeObject(res.data);
  }
}
