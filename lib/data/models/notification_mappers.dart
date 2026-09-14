import '../../domain/entities/app_notification.dart';

/// `NotificationResource` → [AppNotification].
///
/// The API row is `{ id, type, payload:{…}, read_at, created_at }` where `type`
/// is the notification class basename and `payload` is its `toArray()`. Both
/// seeded types (`TaskEventNotification`, `FollowUpDueNotification`) put a
/// human sentence in `payload.message`.
AppNotification notificationFromJson(Map<String, dynamic> json) {
  final payload = json['payload'] is Map
      ? (json['payload'] as Map).cast<String, dynamic>()
      : const <String, dynamic>{};
  final type = (json['type'] as String? ?? '').toLowerCase();
  final kind = _kindFor(type, payload);

  return AppNotification(
    id: json['id'].toString(),
    title: _titleFor(type, payload),
    body: payload['message'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    read: json['read_at'] != null,
    kind: kind,
    route: _routeFor(kind, payload),
  );
}

NotificationKind _kindFor(String type, Map<String, dynamic> payload) {
  if (type.contains('task') || payload.containsKey('task_id')) {
    return NotificationKind.task;
  }
  if (type.contains('followup') || payload.containsKey('follow_up_id')) {
    return NotificationKind.followUp;
  }
  if (type.contains('leave')) return NotificationKind.leave;
  if (type.contains('payment') || type.contains('invoice')) {
    return NotificationKind.payment;
  }
  if (type.contains('visa')) return NotificationKind.visaDeadline;
  if (type.contains('passport') || type.contains('document')) {
    return NotificationKind.documentExpiry;
  }
  return NotificationKind.general;
}

String _titleFor(String type, Map<String, dynamic> payload) {
  final taskTitle = payload['task_title'];
  if (taskTitle is String && taskTitle.isNotEmpty) return taskTitle;
  final subject = payload['subject'];
  if (subject is String && subject.isNotEmpty) return subject;
  // Fall back to a spaced-out class name, e.g. "task event".
  return type
      .replaceAll('notification', '')
      .replaceAllMapped(RegExp('([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .trim();
}

String? _routeFor(NotificationKind kind, Map<String, dynamic> payload) {
  // In-app deep links land as feature routes; extend as the payloads grow.
  return null;
}
