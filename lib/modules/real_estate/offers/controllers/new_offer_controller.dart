import 'package:get/get.dart';

import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/offer.dart';
import '../../../../domain/repositories/offer_repository.dart';

/// Opens a brand-new negotiation thread for a project unit — reached from a
/// project's unit list ("Make offer").
class NewOfferController extends GetxController {
  NewOfferController(
    this._repo, {
    required this.projectId,
    required this.projectTitle,
    required this.unitId,
    required this.unitName,
  });

  final OfferRepository _repo;
  final String projectId;
  final String projectTitle;
  final String unitId;
  final String unitName;

  final Rxn<Customer> lead = Rxn<Customer>();
  final RxString amount = ''.obs;
  final RxString note = ''.obs;
  final RxBool busy = false.obs;
  final RxnString error = RxnString();

  Future<Offer?> submit() async {
    final selectedLead = lead.value;
    final parsedAmount = num.tryParse(amount.value.trim());
    if (selectedLead == null || parsedAmount == null || parsedAmount <= 0) {
      error.value = 'Pick a lead and enter a valid amount.';
      return null;
    }
    busy.value = true;
    error.value = null;
    final result = await _repo.makeOffer(
      leadId: selectedLead.id,
      leadName: selectedLead.name,
      unitId: unitId,
      unitName: unitName,
      projectId: projectId,
      projectTitle: projectTitle,
      offeredPrice: parsedAmount,
      offeredBy: OfferParty.seller,
      notes: note.value.trim().isEmpty ? null : note.value.trim(),
    );
    busy.value = false;
    return result.fold((o) => o, (f) {
      error.value = f.message;
      return null;
    });
  }
}
