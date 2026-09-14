import '../../core/error/result.dart';
import '../entities/site_visit.dart';

/// Site-visit scheduling (roadmap §7, between Property Match and
/// Negotiation).
abstract interface class SiteVisitRepository {
  /// Every site visit the current tenant staff may see, soonest first.
  /// [status] optionally filters to one [SiteVisitStatus] value.
  Future<Result<List<SiteVisit>>> list({String? status});

  /// Exactly one of [unitId] / [projectId] must be given — the backend
  /// requires whichever the other is missing. [leadName]/[unitName]/
  /// [projectTitle] are never sent to the backend; they are only threaded
  /// through so a fake repository can build a self-consistent [SiteVisit]
  /// without a network round trip.
  Future<Result<SiteVisit>> schedule({
    required String leadId,
    required String leadName,
    required DateTime scheduledAt,
    String? unitId,
    String? unitName,
    String? projectId,
    String? projectTitle,
    String? conductedByEmployeeId,
  });

  Future<Result<SiteVisit>> complete(String id, {String? feedback});

  Future<Result<SiteVisit>> cancel(String id);
}
