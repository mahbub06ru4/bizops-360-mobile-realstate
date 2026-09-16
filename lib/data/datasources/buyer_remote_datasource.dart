import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the assumed buyer-persona endpoints — see
/// `domain/repositories/buyer_repository.dart` for the full documented
/// contract this was written against. No backend module for these exists yet
/// (`docs/HANDOFF.md` Phase 2); this class exists so wiring the real backend
/// later is a one-file change, following this app's `USE_FAKE_DATA` /
/// `FakeXRepository` convention (see `CLAUDE.md` rule 6).
///
/// **Phase 3 marketplace note (concrete backend requirement, not yet built):**
/// `GET /buyer/projects` as drafted below still assumes a single scoped
/// tenant. A genuine cross-tenant marketplace (roadmap §7 Phase 3 DoD — an
/// unrelated second developer self-signs-up and appears in the marketplace)
/// needs a **platform-level** endpoint instead, because
/// `GET /api/v1/real-estate/projects` is tenant-scoped by `BelongsToTenant`'s
/// global scope and a buyer session (no `tenant_id`) cannot call it as-is:
/// ```
/// GET /api/v1/real-estate/marketplace/projects?location=<query>
/// ```
/// - Bypasses the `BelongsToTenant` global scope entirely (a platform/public
///   query, not a tenant query) — returns projects across every tenant.
/// - Hard-filters to `status=verified` only server-side (never trust a client
///   filter for what is publicly listable).
/// - Gated by ordinary authenticated-buyer auth (whatever that session type
///   ends up being — `docs/HANDOFF.md` Phase 2 flags no backend buyer-auth
///   exists yet either), not by `industry:real_estate` + `tenant` like every
///   other real-estate route.
/// - Each project in the response should embed a lightweight `tenant`
///   (`{id, name}`) or a top-level `developer_name` field so the listing can
///   show which developer/agency it belongs to — `realEstateProjectFromJson`
///   already reads either shape (`developer_name`, falling back to
///   `tenant.name`).
///
/// [browseVerified] below is left calling the single-tenant `/buyer/projects`
/// shape (matching the rest of this class) until that endpoint exists;
/// [FakeBuyerRepository] is what actually demonstrates the multi-developer
/// marketplace client-side today.
class BuyerRemoteDataSource {
  BuyerRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> browseVerified({String? query}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/buyer/projects',
      query: {
        'verified': true,
        if (query != null && query.isNotEmpty) 'location': query,
      },
    );
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> savedProjects() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/buyer/saved-projects',
    );
    return envelopeList(res.data);
  }

  Future<void> saveProject(String projectId) async {
    await _client.post<Map<String, dynamic>>(
      '/buyer/saved-projects',
      body: {'project_id': projectId},
    );
  }

  Future<void> unsaveProject(String projectId) async {
    await _client.delete<Map<String, dynamic>>(
      '/buyer/saved-projects/$projectId',
    );
  }

  Future<List<Map<String, dynamic>>> myBookings() async {
    final res = await _client.get<Map<String, dynamic>>('/buyer/bookings');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> booking(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/buyer/bookings/$id');
    return envelopeObject(res.data);
  }
}
