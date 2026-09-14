import '../../core/error/result.dart';
import '../entities/property_match.dart';
import '../entities/property_requirement.dart';
import '../entities/real_estate_project.dart';

/// Requirement capture + rule-based matching (roadmap §7 "Lead → Requirement
/// → Property Match"). Attaches to the existing CRM lead — this module never
/// duplicates the lead/customer entity.
abstract interface class PropertyRequirementRepository {
  /// Every requirement captured for [leadId], newest first.
  Future<Result<List<PropertyRequirement>>> forLead(String leadId);

  /// [leadName] is never sent to the backend (the lead comes from the URL) —
  /// it is only threaded through so a fake repository can build a
  /// self-consistent [PropertyRequirement] without a network round trip.
  Future<Result<PropertyRequirement>> create({
    required String leadId,
    required String leadName,
    num? budgetMin,
    num? budgetMax,
    String? preferredLocations,
    ProjectType? unitType,
    int? bedroomsMin,
    RequirementPurpose? purpose,
    String? notes,
  });

  /// Runs rule-based matching for [requirementId] against the available-unit
  /// catalogue and returns the resulting matches.
  Future<Result<List<PropertyMatch>>> match(String requirementId);

  /// The matches already generated for [requirementId] (without re-running
  /// matching).
  Future<Result<List<PropertyMatch>>> matchesFor(String requirementId);
}
