import '../../domain/entities/traveller.dart';
import '../../domain/entities/visa_application.dart';

/// JSON → entity mappers for the travel module (`/travellers`,
/// `/visa-applications`). The data source has already unwrapped the envelope,
/// so these see the inner resource objects.

DateTime? _date(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

Traveller travellerFromJson(Map<String, dynamic> json) {
  return Traveller(
    id: json['id'].toString(),
    name: json['full_name'] as String? ?? '',
    nationality: json['nationality'] as String? ?? '',
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    dateOfBirth: _date(json['date_of_birth']),
    passportNumber: json['passport_number'] as String?,
    passportExpiry: _date(json['passport_expiry']),
  );
}

/// Backend `stage` string → [VisaStage]. `cancelled` has no mobile equivalent
/// and collapses onto `rejected` (both are terminal, decision-negative).
const Map<String, VisaStage> visaStageFromApi = {
  'draft': VisaStage.caseOpened,
  'documents_pending': VisaStage.docsRequired,
  'documents_collected': VisaStage.docsCollected,
  'submitted': VisaStage.submitted,
  'processing': VisaStage.processing,
  'approved': VisaStage.approved,
  'rejected': VisaStage.rejected,
  'cancelled': VisaStage.rejected,
};

VisaApplication visaApplicationFromJson(Map<String, dynamic> json) {
  final traveller = json['traveller'];
  final requirements = json['requirements'];

  return VisaApplication(
    id: json['id'].toString(),
    travellerName: traveller is Map
        ? (traveller['full_name'] as String? ?? '')
        : '',
    country: json['destination_country'] as String? ?? '',
    category: json['visa_type'] as String? ?? '',
    stage: visaStageFromApi[json['stage']] ?? VisaStage.caseOpened,
    docs: requirements is List
        ? requirements
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (r) => VisaDoc(
                  name: r['name'] as String? ?? '',
                  collected: r['collected'] == true,
                ),
              )
              .toList(growable: false)
        : const [],
    submittedAt: _date(json['submitted_on']),
    decisionAt: _date(json['decision_on']),
  );
}

/// Finds the requirement id for [docName] in a raw visa-application object, or
/// `null` if the application has no such requirement.
String? requirementIdByName(Map<String, dynamic> application, String docName) {
  final requirements = application['requirements'];
  if (requirements is! List) return null;
  for (final r in requirements.whereType<Map<dynamic, dynamic>>()) {
    if (r['name'] == docName) return r['id']?.toString();
  }
  return null;
}

bool requirementCollected(Map<String, dynamic> application, String docName) {
  final requirements = application['requirements'];
  if (requirements is! List) return false;
  for (final r in requirements.whereType<Map<dynamic, dynamic>>()) {
    if (r['name'] == docName) return r['collected'] == true;
  }
  return false;
}
