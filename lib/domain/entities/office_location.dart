import 'package:equatable/equatable.dart';

/// The geofence + working hours HR/admin set for attendance punches.
///
/// A single office per tenant for now — multi-branch geofencing is a later
/// extension, not something the current backend or UI models.
class OfficeLocation extends Equatable {
  const OfficeLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.startTime,
    required this.endTime,
  });

  final String label;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  /// 24h `HH:mm`, e.g. `10:00`.
  final String startTime;

  /// 24h `HH:mm`, e.g. `18:00`.
  final String endTime;

  OfficeLocation copyWith({
    String? label,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? startTime,
    String? endTime,
  }) => OfficeLocation(
    label: label ?? this.label,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
  );

  @override
  List<Object?> get props => [
    label,
    latitude,
    longitude,
    radiusMeters,
    startTime,
    endTime,
  ];
}
