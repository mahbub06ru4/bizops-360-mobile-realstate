import 'package:equatable/equatable.dart';

enum SiteVisitStatus { scheduled, completed, cancelled, noShow }

/// A scheduled visit for a lead to see a unit — or, when no specific unit is
/// picked yet, a whole project — in person (roadmap §7 pipeline stage
/// between Property Match and Negotiation). Exactly one of [unitId] /
/// [projectId] is set by the backend (`unit_id`/`project_id` are each
/// nullable, but one is required). Denormalizes the lead/unit/project display
/// names from the response's embedded `lead`/`unit`/`project` objects,
/// matching the pattern already used by [Invoice.customerName] — the
/// list/detail screens never need a second lookup just to render a row.
class SiteVisit extends Equatable {
  const SiteVisit({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.scheduledAt,
    required this.status,
    this.unitId,
    this.unitName,
    this.projectId,
    this.projectTitle,
    this.conductedByEmployeeId,
    this.feedback,
    this.createdAt,
  });

  final String id;
  final String leadId;
  final String leadName;
  final String? unitId;
  final String? unitName;
  final String? projectId;
  final String? projectTitle;
  final DateTime scheduledAt;
  final SiteVisitStatus status;
  final String? conductedByEmployeeId;

  /// Set once the visit is completed — the backend has no separate `notes`
  /// field, only this post-visit write-up.
  final String? feedback;

  final DateTime? createdAt;

  bool get isUpcoming =>
      status == SiteVisitStatus.scheduled &&
      scheduledAt.isAfter(DateTime.now());
  bool get isOverdue =>
      status == SiteVisitStatus.scheduled &&
      scheduledAt.isBefore(DateTime.now());

  SiteVisit copyWith({SiteVisitStatus? status, String? feedback}) => SiteVisit(
    id: id,
    leadId: leadId,
    leadName: leadName,
    unitId: unitId,
    unitName: unitName,
    projectId: projectId,
    projectTitle: projectTitle,
    scheduledAt: scheduledAt,
    status: status ?? this.status,
    conductedByEmployeeId: conductedByEmployeeId,
    feedback: feedback ?? this.feedback,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    leadId,
    leadName,
    unitId,
    unitName,
    projectId,
    projectTitle,
    scheduledAt,
    status,
    conductedByEmployeeId,
    feedback,
    createdAt,
  ];
}
