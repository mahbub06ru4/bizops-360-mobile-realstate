import '../../domain/entities/customer.dart';
import '../../domain/entities/follow_up.dart';

/// `CustomerResource` → [Customer].
///
/// The pipeline lives on *leads*; a `Customer` is a converted lead, so it has no
/// stage of its own — every row maps to [PipelineStage.converted]. Deal value
/// isn't on the customer record either.
Customer customerFromJson(Map<String, dynamic> json) {
  return Customer(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    stage: PipelineStage.converted,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    note: json['company'] as String?,
    lastActivityAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );
}

/// The `activities` array from `GET /customers/{id}/history`.
List<CustomerActivity> customerHistoryFromJson(Map<String, dynamic> history) {
  final activities = history['activities'];
  if (activities is! List) return const [];
  return activities
      .whereType<Map<dynamic, dynamic>>()
      .map(
        (a) => CustomerActivity(
          id: a['id'].toString(),
          at:
              DateTime.tryParse(a['created_at'] as String? ?? '') ??
              DateTime.now(),
          summary: a['description'] as String? ?? (a['event'] as String? ?? ''),
          detail: a['causer_name'] as String?,
        ),
      )
      .toList(growable: false);
}

const Map<String, FollowUpChannel> _channelFromApi = {
  'call': FollowUpChannel.call,
  'whatsapp': FollowUpChannel.whatsapp,
  'email': FollowUpChannel.email,
  'meeting': FollowUpChannel.meeting,
  'visit': FollowUpChannel.visit,
  'sms': FollowUpChannel.call,
};

/// `FollowUpResource` → [FollowUp]. The resource carries the polymorphic
/// `followupable_type` / `_id` but not the subject's display name, so the
/// customer label is derived from those until the API includes it.
FollowUp followUpFromJson(Map<String, dynamic> json) {
  final status = json['status'] as String? ?? 'pending';
  final subjectType = json['followupable_type'] as String? ?? 'Customer';
  final subjectId = json['followupable_id']?.toString() ?? '';

  return FollowUp(
    id: json['id'].toString(),
    customerId: subjectId,
    customerName: '$subjectType #$subjectId',
    dueAt: DateTime.tryParse(json['due_at'] as String? ?? '') ?? DateTime.now(),
    channel: _channelFromApi[json['type']] ?? FollowUpChannel.call,
    note: json['notes'] as String? ?? '',
    done: status == 'completed' || status == 'cancelled',
  );
}

const Map<FollowUpOutcome, String> followUpOutcomeToApi = {
  FollowUpOutcome.reached: 'Reached',
  FollowUpOutcome.noAnswer: 'No answer',
  FollowUpOutcome.rescheduled: 'Rescheduled',
  FollowUpOutcome.notInterested: 'Not interested',
  FollowUpOutcome.won: 'Won',
};
