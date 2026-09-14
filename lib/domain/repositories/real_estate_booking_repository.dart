import '../../core/error/result.dart';
import '../entities/installment.dart';
import '../entities/installment_plan.dart';
import '../entities/real_estate_booking.dart';

/// Reservation → Booking → Installment (roadmap §7), wired into the existing
/// Finance module for the actual invoice/payment side — [generateInvoice]
/// creates (or links) a Finance `Invoice`, it does not maintain a parallel
/// ledger.
abstract interface class RealEstateBookingRepository {
  /// Every booking the current tenant staff may see, newest first.
  /// [status] optionally filters to one [RealEstateBookingStatus] value.
  Future<Result<List<RealEstateBooking>>> list({String? status});

  Future<Result<RealEstateBooking>> getById(String id);

  /// Reserves a unit from an accepted [Offer] — the roadmap's
  /// "Reservation" step. The backend requires [offerId]'s offer to already
  /// be accepted.
  Future<Result<RealEstateBooking>> reserve({required String offerId});

  Future<Result<RealEstateBooking>> confirm(String bookingId);

  Future<Result<RealEstateBooking>> cancel(String bookingId);

  /// The booking's installment plan, if one has been created — only ever
  /// fetched from the booking's own detail response (the backend omits this
  /// key entirely on list responses).
  Future<Result<InstallmentPlan?>> planFor(String bookingId);

  /// Creates the down-payment + equal-split installment schedule for
  /// [bookingId]; the backend requires the booking to already be `booked` or
  /// `completed`. [downPaymentAmount] is an absolute BDT amount, not a
  /// percent.
  Future<Result<InstallmentPlan>> createPlan(
    String bookingId, {
    required num downPaymentAmount,
    required int installmentCount,
    required InstallmentFrequency frequency,
    required DateTime startDate,
  });

  Future<Result<List<Installment>>> installmentsFor(String planId);

  /// Raises a Finance `Invoice` for [installmentId] and returns the updated
  /// installment (`status: invoiced`, `invoiceId` set). Navigate to the
  /// existing invoice detail screen with that id afterwards.
  Future<Result<Installment>> generateInvoice(String installmentId);

  /// Manual settlement for Phase 1 (no payment-gateway reconciliation yet).
  Future<Result<Installment>> markPaid(String installmentId);
}
