import 'package:equatable/equatable.dart';

class LocationFix extends Equatable {
  const LocationFix(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Why a location fix could not be obtained — surfaced so the caller can show
/// a precise message (e.g. "enable location services" vs "grant permission").
enum LocationFailureReason { serviceDisabled, permissionDenied, unavailable }

class LocationFailure implements Exception {
  const LocationFailure(this.reason);

  final LocationFailureReason reason;
}
