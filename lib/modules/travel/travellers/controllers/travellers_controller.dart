import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/traveller.dart';
import '../../../../domain/repositories/traveller_repository.dart';

class TravellersController extends GetxController {
  TravellersController(this._repo);

  final TravellerRepository _repo;

  final Rx<AsyncValue<List<Traveller>>> state =
      const AsyncValue<List<Traveller>>.loading().obs;
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.travellers()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  final RxnString createError = RxnString();

  /// Creates a traveller, then reloads the list from the source so the new row
  /// reflects exactly what the backend stored. Returns true on success.
  Future<bool> create({
    required String name,
    String? nationality,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
  }) async {
    createError.value = null;
    final result = await _repo.create(
      name: name,
      nationality: nationality,
      phone: phone,
      passportNumber: passportNumber,
      passportExpiry: passportExpiry,
    );
    return result.fold(
      (_) {
        load();
        return true;
      },
      (f) {
        createError.value = f.message;
        return false;
      },
    );
  }

  List<Traveller> get visible {
    final all = state.value.valueOrNull ?? const [];
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (t) =>
              t.name.toLowerCase().contains(q) ||
              (t.passportNumber?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}
