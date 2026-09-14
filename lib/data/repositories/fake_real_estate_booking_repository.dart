import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/offer_repository.dart';
import '../../domain/repositories/real_estate_booking_repository.dart';

/// In-memory bookings + installment schedules for UI-first development.
/// Depends on [OfferRepository] (to pull an accepted offer's terms when
/// reserving) and [InvoiceRepository] (to raise a real Finance invoice on
/// "generate invoice", per the roadmap's "wired into the existing Finance
/// module" instruction) — both injected by the binding, the same way
/// [RealEstateProjectRepositoryImpl] is handed its data source rather than
/// looking one up itself.
class FakeRealEstateBookingRepository implements RealEstateBookingRepository {
  FakeRealEstateBookingRepository(this._offers, this._invoices)
    : _items = _seedBookings(),
      _plans = _seedPlans(),
      _installments = _seedInstallments();

  final OfferRepository _offers;
  final InvoiceRepository _invoices;

  List<RealEstateBooking> _items;
  List<InstallmentPlan> _plans;
  List<Installment> _installments;

  var _nextBookingId = 700;
  var _nextPlanId = 750;
  var _nextInstallmentId = 780;

  static DateTime _ago(int days) =>
      DateTime.now().subtract(Duration(days: days));

  static List<RealEstateBooking> _seedBookings() => [
    RealEstateBooking(
      id: 'bk1',
      leadId: 'c2',
      leadName: 'Nusrat Jahan',
      unitId: 'u3',
      unitName: 'A-3B',
      projectId: 'rp2',
      projectTitle: 'Khulshi Heights',
      acceptedOfferId: 'o3',
      agreedPrice: 13800000,
      status: RealEstateBookingStatus.booked,
      bookedAt: _ago(3),
      createdAt: _ago(3),
    ),
  ];

  static List<InstallmentPlan> _seedPlans() => [
    InstallmentPlan(
      id: 'plan1',
      bookingId: 'bk1',
      downPaymentAmount: 2760000, // 20% of 13,800,000
      installmentCount: 7,
      frequency: InstallmentFrequency.monthly,
      startDate: _ago(3),
    ),
  ];

  static List<Installment> _seedInstallments() {
    // financed = 13,800,000 - 2,760,000 (20%) = 11,040,000 over 7
    // installments — chosen so the split doesn't divide evenly, demoing the
    // "last installment absorbs the rounding remainder" rule.
    final amounts = splitInstallmentAmounts(11040000, 7);
    final statuses = [
      InstallmentStatus.paid,
      InstallmentStatus.paid,
      InstallmentStatus.invoiced,
      InstallmentStatus.pending,
      InstallmentStatus.pending,
      InstallmentStatus.overdue,
      InstallmentStatus.pending,
    ];
    return [
      for (var i = 0; i < amounts.length; i++)
        Installment(
          id: 'inst${i + 1}',
          installmentPlanId: 'plan1',
          sequence: i + 1,
          amount: amounts[i],
          dueDate: _ago(3).add(Duration(days: 30 * (i + 1))),
          status: statuses[i],
          invoiceId:
              statuses[i] == InstallmentStatus.invoiced ||
                  statuses[i] == InstallmentStatus.paid
              ? (i == 0 ? 'inv1' : null)
              : null,
        ),
    ];
  }

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  RealEstateBooking? _find(String id) =>
      _items.where((b) => b.id == id).firstOrNull;

  Result<RealEstateBooking> _replace(RealEstateBooking b) {
    _items = [
      for (final x in _items)
        if (x.id == b.id) b else x,
    ];
    return Result.ok(b);
  }

  @override
  Future<Result<List<RealEstateBooking>>> list({String? status}) => _delayed(
    Result.ok(
      List.unmodifiable(
        <RealEstateBooking>[
          for (final b in _items)
            if (status == null || b.status.name == status) b,
        ]..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        ),
      ),
    ),
  );

  @override
  Future<Result<RealEstateBooking>> getById(String id) {
    final b = _find(id);
    return _delayed(
      b == null ? const Result.err(NotFoundFailure()) : Result.ok(b),
    );
  }

  @override
  Future<Result<RealEstateBooking>> reserve({required String offerId}) async {
    final offerResult = await _offers.getById(offerId);
    final offer = offerResult.valueOrNull;
    if (offer == null) return const Result.err(NotFoundFailure());
    if (offer.status != OfferStatus.accepted) {
      return const Result.err(
        ValidationFailure('Only an accepted offer can be reserved.', {}),
      );
    }
    final booking = RealEstateBooking(
      id: 'bk${_nextBookingId++}',
      leadId: offer.leadId,
      leadName: offer.leadName,
      unitId: offer.unitId,
      unitName: offer.unitName,
      projectId: offer.projectId,
      projectTitle: offer.projectTitle,
      acceptedOfferId: offer.id,
      agreedPrice: offer.offeredPrice,
      status: RealEstateBookingStatus.reserved,
      createdAt: DateTime.now(),
    );
    _items = [booking, ..._items];
    return Result.ok(booking);
  }

  @override
  Future<Result<RealEstateBooking>> confirm(String bookingId) {
    final b = _find(bookingId);
    if (b == null) return _delayed(const Result.err(NotFoundFailure()));
    if (b.status != RealEstateBookingStatus.reserved) {
      return _delayed(
        Result.err(
          ValidationFailure(
            'A ${b.status.name} booking cannot be confirmed.',
            const {},
          ),
        ),
      );
    }
    return _delayed(
      _replace(b.copyWith(status: RealEstateBookingStatus.booked)),
    );
  }

  @override
  Future<Result<RealEstateBooking>> cancel(String bookingId) {
    final b = _find(bookingId);
    if (b == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(
      _replace(b.copyWith(status: RealEstateBookingStatus.cancelled)),
    );
  }

  @override
  Future<Result<InstallmentPlan?>> planFor(String bookingId) => _delayed(
    Result.ok(_plans.where((p) => p.bookingId == bookingId).firstOrNull),
  );

  @override
  Future<Result<InstallmentPlan>> createPlan(
    String bookingId, {
    required num downPaymentAmount,
    required int installmentCount,
    required InstallmentFrequency frequency,
    required DateTime startDate,
  }) {
    final booking = _find(bookingId);
    if (booking == null) return _delayed(const Result.err(NotFoundFailure()));
    if (booking.status != RealEstateBookingStatus.booked &&
        booking.status != RealEstateBookingStatus.completed) {
      return _delayed(
        const Result.err(
          ValidationFailure(
            'The booking must be booked before an installment plan can be created.',
            {},
          ),
        ),
      );
    }
    if (_plans.any((p) => p.bookingId == bookingId)) {
      return _delayed(
        const Result.err(
          ValidationFailure(
            'This booking already has an installment plan.',
            {},
          ),
        ),
      );
    }
    final financed = booking.agreedPrice - downPaymentAmount;
    final amounts = splitInstallmentAmounts(financed, installmentCount);
    final installments = [
      for (var i = 0; i < amounts.length; i++)
        Installment(
          id: 'inst${_nextInstallmentId++}',
          installmentPlanId: 'plan$_nextPlanId',
          sequence: i + 1,
          amount: amounts[i],
          dueDate: startDate.add(Duration(days: 30 * (i + 1))),
          status: InstallmentStatus.pending,
        ),
    ];
    final plan = InstallmentPlan(
      id: 'plan${_nextPlanId++}',
      bookingId: bookingId,
      downPaymentAmount: downPaymentAmount,
      installmentCount: installmentCount,
      frequency: frequency,
      startDate: startDate,
      installments: installments,
      createdAt: DateTime.now(),
    );
    _plans = [...(_plans), plan];
    _installments = [...(_installments), ...installments];
    return _delayed(Result.ok(plan));
  }

  @override
  Future<Result<List<Installment>>> installmentsFor(String planId) => _delayed(
    Result.ok(
      List.unmodifiable(
        _installments.where((i) => i.installmentPlanId == planId).toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence)),
      ),
    ),
  );

  Installment? _findInstallment(String id) =>
      _installments.where((i) => i.id == id).firstOrNull;

  Result<Installment> _replaceInstallment(Installment i) {
    _installments = [
      for (final x in _installments)
        if (x.id == i.id) i else x,
    ];
    return Result.ok(i);
  }

  @override
  Future<Result<Installment>> generateInvoice(String installmentId) async {
    final installment = _findInstallment(installmentId);
    if (installment == null) return const Result.err(NotFoundFailure());
    if (installment.status != InstallmentStatus.pending &&
        installment.status != InstallmentStatus.overdue) {
      return const Result.err(
        ValidationFailure(
          'An invoice was already raised for this installment.',
          {},
        ),
      );
    }
    final plan = _plans
        .where((p) => p.id == installment.installmentPlanId)
        .firstOrNull;
    final booking = plan == null ? null : _find(plan.bookingId);
    final invoiceResult = await _invoices.createFromReference(
      customerName: booking?.leadName ?? 'Buyer',
      amount: installment.amount,
      dueDate: installment.dueDate,
      bookingReference: booking?.id,
    );
    final invoice = invoiceResult.valueOrNull;
    if (invoice == null) {
      return Result.err(invoiceResult.failureOrNull ?? const UnknownFailure());
    }
    return _replaceInstallment(
      installment.copyWith(
        status: InstallmentStatus.invoiced,
        invoiceId: invoice.id,
      ),
    );
  }

  @override
  Future<Result<Installment>> markPaid(String installmentId) async {
    final installment = _findInstallment(installmentId);
    if (installment == null) return const Result.err(NotFoundFailure());
    if (installment.invoiceId != null) {
      // Best-effort: keep the linked Finance invoice's paid total in sync.
      await _invoices.recordPayment(
        invoiceId: installment.invoiceId!,
        amount: installment.amount,
        method: 'Manual',
        note: 'Marked paid from the booking installment schedule.',
      );
    }
    return _replaceInstallment(
      installment.copyWith(status: InstallmentStatus.paid),
    );
  }
}
