import '../../core/error/result.dart';
import '../entities/installment_plan.dart';
import '../entities/real_estate_booking.dart';
import '../entities/real_estate_project.dart';

/// The buyer persona's own repository (roadmap §7 Phase 2 — "Buyer journey &
/// trust"). Distinct from [RealEstateProjectRepository]/
/// [RealEstateBookingRepository] because the buyer session carries no
/// tenant/permissions to scope those tenant-staff-facing repositories with —
/// this is a platform-level view over (for Phase 2, single-tenant) verified
/// listings plus the buyer's own saved list and bookings.
///
/// No backend buyer endpoints exist yet. [BuyerRepositoryImpl] is written
/// against this assumed REST contract for later reconciliation once the
/// backend module lands (see `docs/HANDOFF.md` Phase 2 for how the rest of
/// this app's real/fake repository pairs are wired):
///
/// ```
/// GET    /buyer/projects?verified=true&location=<query>   verified-only, optional
///                                                          substring match against
///                                                          division/district/area/
///                                                          sector/road/landmarks
/// GET    /buyer/saved-projects                              -> [{project_id}] or full
///                                                              project envelopes
/// POST   /buyer/saved-projects                              body: {project_id}
/// DELETE /buyer/saved-projects/{projectId}
/// GET    /buyer/bookings                                    the buyer's own bookings
/// GET    /buyer/bookings/{booking}                          embeds installment_plan,
///                                                            mirroring
///                                                            GET /real-estate-bookings/{booking}
/// ```
abstract interface class BuyerRepository {
  /// Verified listings only. [query] does a plain substring match against the
  /// project's location fields (area/district/division/sector/road/landmarks)
  /// — no NLP, mirroring the backend's own
  /// `MatchRequirementToUnits.locationMatches()`.
  Future<Result<List<RealEstateProject>>> browseVerified({String? query});

  /// The ids of the buyer's saved projects.
  Future<Result<List<String>>> savedProjectIds();

  Future<Result<void>> saveProject(String projectId);

  Future<Result<void>> unsaveProject(String projectId);

  /// The buyer's own bookings, newest first.
  Future<Result<List<RealEstateBooking>>> myBookings();

  /// The installment plan for one of the buyer's own bookings, if one has
  /// been created.
  Future<Result<InstallmentPlan>> installmentPlanFor(String bookingId);
}
