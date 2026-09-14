import 'package:equatable/equatable.dart';

enum RealEstateBookingStatus { reserved, booked, cancelled, completed }

/// The outcome of an accepted [Offer] — a reserved/booked/completed sale
/// against one unit (roadmap §7 "Reservation → Booking"). Booking to
/// installment plan is 1:1 in Phase 1 (no partial/multi-unit bookings yet).
/// [projectId]/[projectTitle] are derived from the embedded unit's own
/// `project_id`/`project_name` (the backend has no separate project embed on
/// a booking).
class RealEstateBooking extends Equatable {
  const RealEstateBooking({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.unitId,
    required this.unitName,
    required this.acceptedOfferId,
    required this.agreedPrice,
    required this.status,
    this.projectId = '',
    this.projectTitle = '',
    this.customerId,
    this.bookedAt,
    this.createdAt,
  });

  final String id;
  final String leadId;
  final String leadName;
  final String projectId;
  final String projectTitle;
  final String unitId;
  final String unitName;

  /// The accepted [Offer.id] this booking was reserved from.
  final String acceptedOfferId;

  /// Set once [RealEstateBookingStatus.booked] — the CRM customer the lead
  /// was converted into.
  final String? customerId;

  /// The accepted sale price, BDT.
  final num agreedPrice;
  final RealEstateBookingStatus status;

  /// Set when the booking moves to [RealEstateBookingStatus.booked].
  final DateTime? bookedAt;

  final DateTime? createdAt;

  RealEstateBooking copyWith({RealEstateBookingStatus? status}) =>
      RealEstateBooking(
        id: id,
        leadId: leadId,
        leadName: leadName,
        unitId: unitId,
        unitName: unitName,
        acceptedOfferId: acceptedOfferId,
        agreedPrice: agreedPrice,
        status: status ?? this.status,
        projectId: projectId,
        projectTitle: projectTitle,
        customerId: customerId,
        bookedAt: bookedAt,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
    id,
    leadId,
    leadName,
    projectId,
    projectTitle,
    unitId,
    unitName,
    acceptedOfferId,
    customerId,
    agreedPrice,
    status,
    bookedAt,
    createdAt,
  ];
}
