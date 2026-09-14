import 'package:equatable/equatable.dart';

import 'real_estate_project.dart';

/// Why a lead is looking — drives the rule-based matcher's scoring; Phase 1
/// does not otherwise change behaviour by purpose (mirrors the backend's
/// `RequirementPurpose` enum).
enum RequirementPurpose { buy, invest }

/// A buyer/lead's structured property requirement — the input to rule-based
/// matching (roadmap §7: "no AI yet"). Attaches to the *existing* CRM
/// [Customer]/lead (`leadId`); this module never duplicates the lead entity.
///
/// The backend has no `status` field on a requirement at all — whether it has
/// been matched yet is derived from whether [PropertyMatch]es exist for it
/// (fetched separately via `PropertyRequirementRepository.matchesFor`), not
/// stored here.
class PropertyRequirement extends Equatable {
  const PropertyRequirement({
    required this.id,
    required this.leadId,
    required this.leadName,
    this.budgetMin,
    this.budgetMax,
    this.preferredLocations,
    this.unitType,
    this.bedroomsMin,
    this.purpose = RequirementPurpose.buy,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String leadId;
  final String leadName;

  /// BDT.
  final num? budgetMin;
  final num? budgetMax;

  /// Free-text preferred areas, e.g. "Uttara, Mirpur" — no geo lookup in
  /// Phase 1.
  final String? preferredLocations;

  final ProjectType? unitType;
  final int? bedroomsMin;
  final RequirementPurpose purpose;

  final String? notes;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    leadId,
    leadName,
    budgetMin,
    budgetMax,
    preferredLocations,
    unitType,
    bedroomsMin,
    purpose,
    notes,
    createdAt,
  ];
}
