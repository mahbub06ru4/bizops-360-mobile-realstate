import 'package:equatable/equatable.dart';

import 'unit.dart';

/// Lifecycle of a suggestion as the sales team works through it (mirrors the
/// backend's `PropertyMatchStatus` enum). The mobile app never transitions
/// this itself in Phase 1 — it only renders whatever the backend returns.
enum PropertyMatchStatus { suggested, viewed, interested, rejected }

/// One rule-based match of a [PropertyRequirement] against a unit somewhere
/// in the project catalogue (roadmap §7 — "rule-based matching (no AI yet)").
/// [matchScore] is a simple 0-100 fit score from the backend's filter rules
/// (budget proximity, free-text location match, minimum bedrooms); the
/// mobile app never computes it, only renders it.
class PropertyMatch extends Equatable {
  const PropertyMatch({
    required this.id,
    required this.requirementId,
    required this.unitId,
    required this.matchScore,
    required this.status,
    this.unit,
    this.projectId,
    this.projectName,
    this.createdAt,
  });

  final String id;
  final String requirementId;
  final String unitId;

  /// 0-100.
  final num matchScore;
  final PropertyMatchStatus status;

  /// The full unit this match points at — embedded on every response that
  /// returns matches (`PropertyRequirementController::show` and `::match`
  /// both eager-load it). Nullable defensively for a response shape that
  /// somehow omits it.
  final Unit? unit;

  /// The unit's parent project — lets a match card link to "view project"
  /// without a second lookup. Null when the backend couldn't resolve it
  /// (e.g. a unit whose building has no project, which shouldn't happen in
  /// practice) or on an older backend that doesn't send this field yet.
  final String? projectId;
  final String? projectName;

  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    requirementId,
    unitId,
    matchScore,
    status,
    unit,
    projectId,
    projectName,
    createdAt,
  ];
}
