import 'package:get/get.dart';

import '../../../../../core/state/async_value.dart';
import '../../../../../domain/entities/installment.dart';
import '../../../../../domain/entities/installment_plan.dart';
import '../../../../../domain/entities/real_estate_booking.dart';
import '../../../../../domain/repositories/buyer_repository.dart';

/// One row of the buyer's "My Properties" dashboard: a booking, its
/// installment plan (if any), and the paid/remaining/next-due figures the
/// roadmap (§7 Phase 2) asks for.
class MyPropertyRow {
  const MyPropertyRow({required this.booking, this.plan});

  final RealEstateBooking booking;
  final InstallmentPlan? plan;

  /// Down payment counts as paid at booking time; each installment counts
  /// once its status is [InstallmentStatus.paid].
  num get paidAmount {
    final plan = this.plan;
    if (plan == null) return 0;
    final installmentsPaid = plan.installments
        .where((i) => i.status == InstallmentStatus.paid)
        .fold<num>(0, (sum, i) => sum + i.amount);
    return plan.downPaymentAmount + installmentsPaid;
  }

  num get remainingAmount => booking.agreedPrice - paidAmount;

  /// The earliest still-unpaid installment, if any.
  Installment? get nextDue {
    final plan = this.plan;
    if (plan == null) return null;
    final unpaid =
        plan.installments
            .where((i) => i.status != InstallmentStatus.paid)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaid.firstOrNull;
  }
}

class MyPropertiesController extends GetxController {
  MyPropertiesController(this._repo);

  final BuyerRepository _repo;

  final Rx<AsyncValue<List<MyPropertyRow>>> state = Rx(const AsyncLoading());

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncLoading();
    final bookingsResult = await _repo.myBookings();
    final result = await bookingsResult.fold((bookings) async {
      final rows = <MyPropertyRow>[];
      for (final booking in bookings) {
        final planResult = await _repo.installmentPlanFor(booking.id);
        rows.add(MyPropertyRow(booking: booking, plan: planResult.valueOrNull));
      }
      return AsyncValue<List<MyPropertyRow>>.data(rows);
    }, (f) async => AsyncValue<List<MyPropertyRow>>.error(f));
    state.value = result;
  }
}
