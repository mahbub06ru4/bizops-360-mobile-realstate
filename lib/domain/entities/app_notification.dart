import 'package:equatable/equatable.dart';

/// What the notification is about — drives the icon and (later) the deep link.
enum NotificationKind {
  task,
  leave,
  payment,
  followUp,
  visaDeadline,
  documentExpiry,
  general,
}

/// One row in the notifications list (`GET /api/v1/notifications`).
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.kind = NotificationKind.general,
    this.route,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final NotificationKind kind;

  /// In-app route to open when tapped, if any.
  final String? route;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    read: read ?? this.read,
    kind: kind,
    route: route,
  );

  @override
  List<Object?> get props => [id, title, body, createdAt, read, kind, route];
}
