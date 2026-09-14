import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/installment.dart';
import '../../../../domain/entities/installment_plan.dart';
import '../../../../domain/entities/real_estate_booking.dart';
import '../../../../domain/repositories/real_estate_booking_repository.dart';

/// Down-payment UX decision (see the repo-wide report): the create-plan
/// dialog keeps its existing "down payment %" text field rather than adding
/// new inputs; this controller converts that percent to the absolute BDT
/// amount the backend requires using the booking's [RealEstateBooking.agreedPrice],
/// and fills `frequency`/`start_date` with sensible defaults (monthly,
/// starting today) since the backend requires both but the UI does not yet
/// collect them.

/// A booking's detail — the reserved/booked unit, the accepted offer price,
/// and (once created) its installment schedule. Installments/invoices are
/// not tracked in a parallel screen; "generate invoice" hands off to the
/// existing Finance invoice detail screen (roadmap §7: wired into Finance,
/// not a new ledger).
class ReBookingDetailController extends GetxController {
  ReBookingDetailController(this._repo, this._id, {RealEstateBooking? seed})
    : booking = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final RealEstateBookingRepository _repo;
  final String _id;

  final Rx<AsyncValue<RealEstateBooking>> booking;
  final Rxn<InstallmentPlan> plan = Rxn<InstallmentPlan>();
  final RxList<Installment> installments = <Installment>[].obs;
  final RxBool loadingPlan = true.obs;
  final RxBool busy = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    if (booking.value is! AsyncData) _loadBooking();
    _loadPlan();
  }

  Future<void> _loadBooking() async {
    booking.value = (await _repo.getById(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> _loadPlan() async {
    loadingPlan.value = true;
    final result = await _repo.planFor(_id);
    final p = result.valueOrNull;
    plan.value = p;
    if (p != null) {
      final items = await _repo.installmentsFor(p.id);
      installments.assignAll(items.valueOrNull ?? const []);
    }
    loadingPlan.value = false;
  }

  Future<bool> confirm() => _actOnBooking(() => _repo.confirm(_id));

  Future<bool> cancel() => _actOnBooking(() => _repo.cancel(_id));

  Future<bool> _actOnBooking(
    Future<Result<RealEstateBooking>> Function() run,
  ) async {
    busy.value = true;
    error.value = null;
    final result = await run();
    busy.value = false;
    return result.fold(
      (b) {
        booking.value = AsyncValue.data(b);
        return true;
      },
      (f) {
        error.value = f.message;
        return false;
      },
    );
  }

  Future<bool> createPlan({
    required num downPaymentPercent,
    required int installmentCount,
  }) async {
    busy.value = true;
    error.value = null;
    final agreedPrice = booking.value.valueOrNull?.agreedPrice ?? 0;
    final now = DateTime.now();
    final result = await _repo.createPlan(
      _id,
      downPaymentAmount: agreedPrice * downPaymentPercent / 100,
      installmentCount: installmentCount,
      frequency: InstallmentFrequency.monthly,
      startDate: DateTime(now.year, now.month, now.day),
    );
    busy.value = false;
    return result.fold(
      (p) {
        plan.value = p;
        _loadPlan();
        return true;
      },
      (f) {
        error.value = f.message;
        return false;
      },
    );
  }

  /// Returns the raised Finance invoice's id on success, so the screen can
  /// navigate straight to its detail.
  Future<String?> generateInvoice(String installmentId) async {
    busy.value = true;
    error.value = null;
    final result = await _repo.generateInvoice(installmentId);
    busy.value = false;
    return result.fold(
      (installment) {
        _replaceInstallment(installment);
        return installment.invoiceId;
      },
      (f) {
        error.value = f.message;
        return null;
      },
    );
  }

  Future<bool> markPaid(String installmentId) async {
    busy.value = true;
    error.value = null;
    final result = await _repo.markPaid(installmentId);
    busy.value = false;
    return result.fold(
      (installment) {
        _replaceInstallment(installment);
        return true;
      },
      (f) {
        error.value = f.message;
        return false;
      },
    );
  }

  void _replaceInstallment(Installment updated) {
    final idx = installments.indexWhere((i) => i.id == updated.id);
    if (idx >= 0) installments[idx] = updated;
  }
}
