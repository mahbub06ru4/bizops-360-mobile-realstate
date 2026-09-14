import '../../domain/entities/installment.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/property_match.dart';
import '../../domain/entities/property_requirement.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/entities/site_visit.dart';
import 'real_estate_mappers.dart' show projectTypeToApi, unitFromJson;

/// JSON <-> entity mapping for the Phase 1 sales-pipeline module. The data
/// source has already unwrapped the envelope, so these see the inner
/// resource objects — matching `Http/Resources/*Resource.php` in
/// `app/Modules/Industry/RealEstate` field-for-field.

const Map<String, ProjectType> _unitTypeFromApi = {
  'land_share': ProjectType.landShare,
  'apartment': ProjectType.apartment,
  'commercial': ProjectType.commercial,
};

const Map<String, RequirementPurpose> _requirementPurposeFromApi = {
  'buy': RequirementPurpose.buy,
  'invest': RequirementPurpose.invest,
};

const Map<RequirementPurpose, String> requirementPurposeToApi = {
  RequirementPurpose.buy: 'buy',
  RequirementPurpose.invest: 'invest',
};

const Map<String, PropertyMatchStatus> _propertyMatchStatusFromApi = {
  'suggested': PropertyMatchStatus.suggested,
  'viewed': PropertyMatchStatus.viewed,
  'interested': PropertyMatchStatus.interested,
  'rejected': PropertyMatchStatus.rejected,
};

const Map<String, SiteVisitStatus> _siteVisitStatusFromApi = {
  'scheduled': SiteVisitStatus.scheduled,
  'completed': SiteVisitStatus.completed,
  'cancelled': SiteVisitStatus.cancelled,
  'no_show': SiteVisitStatus.noShow,
};

const Map<String, OfferParty> _offerPartyFromApi = {
  'buyer': OfferParty.buyer,
  'seller': OfferParty.seller,
};

const Map<OfferParty, String> offerPartyToApi = {
  OfferParty.buyer: 'buyer',
  OfferParty.seller: 'seller',
};

const Map<String, OfferStatus> _offerStatusFromApi = {
  'pending': OfferStatus.pending,
  'countered': OfferStatus.countered,
  'accepted': OfferStatus.accepted,
  'rejected': OfferStatus.rejected,
  'expired': OfferStatus.expired,
};

const Map<String, RealEstateBookingStatus> _bookingStatusFromApi = {
  'reserved': RealEstateBookingStatus.reserved,
  'booked': RealEstateBookingStatus.booked,
  'cancelled': RealEstateBookingStatus.cancelled,
  'completed': RealEstateBookingStatus.completed,
};

const Map<String, InstallmentFrequency> _frequencyFromApi = {
  'monthly': InstallmentFrequency.monthly,
  'quarterly': InstallmentFrequency.quarterly,
};

const Map<InstallmentFrequency, String> installmentFrequencyToApi = {
  InstallmentFrequency.monthly: 'monthly',
  InstallmentFrequency.quarterly: 'quarterly',
};

const Map<String, InstallmentStatus> _installmentStatusFromApi = {
  'pending': InstallmentStatus.pending,
  'invoiced': InstallmentStatus.invoiced,
  'paid': InstallmentStatus.paid,
  'overdue': InstallmentStatus.overdue,
};

num _num(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

DateTime _date(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();

DateTime? _dateOrNull(dynamic v) =>
    v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

List<Map<String, dynamic>> _list(dynamic v) => v is List
    ? v
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false)
    : const [];

/// `id`/`name` for an embedded `lead` object — present whenever the response
/// eager-loaded the `lead` relation.
String? _leadName(dynamic lead) => lead is Map ? lead['name'] as String? : null;

PropertyRequirement propertyRequirementFromJson(Map<String, dynamic> json) {
  final lead = json['lead'];
  return PropertyRequirement(
    id: json['id'].toString(),
    leadId:
        json['lead_id']?.toString() ??
        (lead is Map ? lead['id']?.toString() : null) ??
        '',
    leadName: _leadName(lead) ?? '',
    budgetMin: json['budget_min'] == null ? null : _num(json['budget_min']),
    budgetMax: json['budget_max'] == null ? null : _num(json['budget_max']),
    preferredLocations: json['preferred_locations'] as String?,
    unitType: _unitTypeFromApi[json['unit_type']],
    bedroomsMin: (json['bedrooms_min'] as num?)?.toInt(),
    purpose:
        _requirementPurposeFromApi[json['purpose']] ?? RequirementPurpose.buy,
    notes: json['notes'] as String?,
    createdAt: _dateOrNull(json['created_at']),
  );
}

Map<String, dynamic> propertyRequirementToJson({
  num? budgetMin,
  num? budgetMax,
  String? preferredLocations,
  ProjectType? unitType,
  int? bedroomsMin,
  RequirementPurpose? purpose,
  String? notes,
}) => {
  'budget_min': ?budgetMin,
  'budget_max': ?budgetMax,
  'preferred_locations': ?preferredLocations,
  'unit_type': ?(unitType == null ? null : projectTypeToApi[unitType]),
  'bedrooms_min': ?bedroomsMin,
  'purpose': ?(purpose == null ? null : requirementPurposeToApi[purpose]),
  'notes': ?notes,
};

PropertyMatch propertyMatchFromJson(Map<String, dynamic> json) {
  final unit = json['unit'];
  final project = json['project'];
  return PropertyMatch(
    id: json['id'].toString(),
    requirementId: json['requirement_id']?.toString() ?? '',
    unitId:
        json['unit_id']?.toString() ??
        (unit is Map ? unit['id']?.toString() : null) ??
        '',
    matchScore: _num(json['match_score']),
    status:
        _propertyMatchStatusFromApi[json['status']] ??
        PropertyMatchStatus.suggested,
    unit: unit is Map ? unitFromJson(unit.cast<String, dynamic>()) : null,
    projectId: project is Map ? project['id']?.toString() : null,
    projectName: project is Map ? project['name'] as String? : null,
    createdAt: _dateOrNull(json['created_at']),
  );
}

/// A lightweight `unit` embed shared by offers/site-visits/bookings —
/// `{id, unit_number, project_id, project_name}` (`UnitSummaryResource`),
/// not the full `UnitResource` a [PropertyMatch] carries.
({String? id, String? number, String? projectId, String? projectName})
_unitSummary(dynamic unit) {
  if (unit is! Map) {
    return (id: null, number: null, projectId: null, projectName: null);
  }
  return (
    id: unit['id']?.toString(),
    number: unit['unit_number'] as String?,
    projectId: unit['project_id']?.toString(),
    projectName: unit['project_name'] as String?,
  );
}

SiteVisit siteVisitFromJson(Map<String, dynamic> json) {
  final lead = json['lead'];
  final unit = _unitSummary(json['unit']);
  final project = json['project'];
  return SiteVisit(
    id: json['id'].toString(),
    leadId:
        json['lead_id']?.toString() ??
        (lead is Map ? lead['id']?.toString() : null) ??
        '',
    leadName: _leadName(lead) ?? '',
    unitId: json['unit_id']?.toString() ?? unit.id,
    unitName: unit.number,
    projectId:
        (project is Map ? project['id']?.toString() : null) ??
        unit.projectId ??
        json['project_id']?.toString(),
    projectTitle:
        (project is Map ? project['name'] as String? : null) ??
        unit.projectName,
    scheduledAt: _date(json['scheduled_at']),
    status:
        _siteVisitStatusFromApi[json['status']] ?? SiteVisitStatus.scheduled,
    conductedByEmployeeId: json['conducted_by_employee_id']?.toString(),
    feedback: json['feedback'] as String?,
    createdAt: _dateOrNull(json['created_at']),
  );
}

Offer offerFromJson(Map<String, dynamic> json) {
  final lead = json['lead'];
  final unit = _unitSummary(json['unit']);
  final counters = json['counter_offers'];
  return Offer(
    id: json['id'].toString(),
    leadId:
        json['lead_id']?.toString() ??
        (lead is Map ? lead['id']?.toString() : null) ??
        '',
    leadName: _leadName(lead) ?? '',
    unitId: json['unit_id']?.toString() ?? unit.id ?? '',
    unitName: unit.number ?? '',
    projectId: unit.projectId ?? '',
    projectTitle: unit.projectName ?? '',
    offeredPrice: _num(json['offered_price']),
    offeredBy: _offerPartyFromApi[json['offered_by']] ?? OfferParty.seller,
    status: _offerStatusFromApi[json['status']] ?? OfferStatus.pending,
    previousOfferId: json['previous_offer_id']?.toString(),
    notes: json['notes'] as String?,
    counterOffers: _list(counters).map(offerFromJson).toList(growable: false),
    createdAt: _dateOrNull(json['created_at']),
  );
}

RealEstateBooking realEstateBookingFromJson(Map<String, dynamic> json) {
  final lead = json['lead'];
  final unit = _unitSummary(json['unit']);
  return RealEstateBooking(
    id: json['id'].toString(),
    leadId:
        json['lead_id']?.toString() ??
        (lead is Map ? lead['id']?.toString() : null) ??
        '',
    leadName: _leadName(lead) ?? '',
    unitId: json['unit_id']?.toString() ?? unit.id ?? '',
    unitName: unit.number ?? '',
    projectId: unit.projectId ?? '',
    projectTitle: unit.projectName ?? '',
    acceptedOfferId: json['accepted_offer_id']?.toString() ?? '',
    customerId: json['customer_id']?.toString(),
    agreedPrice: _num(json['agreed_price']),
    status:
        _bookingStatusFromApi[json['status']] ??
        RealEstateBookingStatus.reserved,
    bookedAt: _dateOrNull(json['booked_at']),
    createdAt: _dateOrNull(json['created_at']),
  );
}

InstallmentPlan installmentPlanFromJson(Map<String, dynamic> json) =>
    InstallmentPlan(
      id: json['id'].toString(),
      bookingId: json['booking_id']?.toString() ?? '',
      downPaymentAmount: _num(json['down_payment_amount']),
      installmentCount: (json['installment_count'] as num?)?.toInt() ?? 0,
      frequency:
          _frequencyFromApi[json['frequency']] ?? InstallmentFrequency.monthly,
      startDate: _date(json['start_date']),
      installments: _list(
        json['installments'],
      ).map(installmentFromJson).toList(growable: false),
      createdAt: _dateOrNull(json['created_at']),
    );

Installment installmentFromJson(Map<String, dynamic> json) => Installment(
  id: json['id'].toString(),
  installmentPlanId: json['installment_plan_id']?.toString() ?? '',
  sequence: (json['sequence'] as num?)?.toInt() ?? 0,
  amount: _num(json['amount']),
  dueDate: _date(json['due_date']),
  status:
      _installmentStatusFromApi[json['status']] ?? InstallmentStatus.pending,
  invoiceId: json['invoice_id']?.toString(),
  createdAt: _dateOrNull(json['created_at']),
);
