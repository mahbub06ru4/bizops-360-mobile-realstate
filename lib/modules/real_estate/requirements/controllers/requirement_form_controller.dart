import 'package:get/get.dart';

import '../../../../domain/entities/property_requirement.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/repositories/property_requirement_repository.dart';

/// Requirement-capture form state, attached to an existing CRM lead
/// (`leadId`/`leadName` are handed in, never re-created here — roadmap §7:
/// "reuses the existing shared CRM lead entity").
class RequirementFormController extends GetxController {
  RequirementFormController(this._repo, this.leadId, this.leadName);

  final PropertyRequirementRepository _repo;
  final String leadId;
  final String leadName;

  final Rxn<ProjectType> unitType = Rxn<ProjectType>();
  final RxString minBudget = ''.obs;
  final RxString maxBudget = ''.obs;
  final RxString preferredLocations = ''.obs;
  final RxString bedroomsMin = ''.obs;
  final Rx<RequirementPurpose> purpose = RequirementPurpose.buy.obs;
  final RxString notes = ''.obs;

  final RxBool busy = false.obs;
  final RxnString error = RxnString();

  num? _numOrNull(String s) => s.trim().isEmpty ? null : num.tryParse(s.trim());
  int? _intOrNull(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());
  String? _strOrNull(String s) => s.trim().isEmpty ? null : s.trim();

  /// Creates the requirement, immediately runs matching against it, and
  /// returns the requirement id on success (the screen navigates to the
  /// matches list with it).
  Future<String?> saveAndMatch() async {
    busy.value = true;
    error.value = null;
    try {
      final created = await _repo.create(
        leadId: leadId,
        leadName: leadName,
        budgetMin: _numOrNull(minBudget.value),
        budgetMax: _numOrNull(maxBudget.value),
        preferredLocations: _strOrNull(preferredLocations.value),
        unitType: unitType.value,
        bedroomsMin: _intOrNull(bedroomsMin.value),
        purpose: purpose.value,
        notes: _strOrNull(notes.value),
      );
      final requirement = created.valueOrNull;
      if (requirement == null) {
        error.value = created.failureOrNull?.message;
        return null;
      }
      await _repo.match(requirement.id);
      return requirement.id;
    } finally {
      busy.value = false;
    }
  }
}
