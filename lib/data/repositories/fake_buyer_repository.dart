import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/repositories/buyer_repository.dart';
import '../../domain/repositories/real_estate_project_repository.dart';

/// In-memory [BuyerRepository] for UI-first development (`Env.useFakeData`).
/// Reads the same seeded catalogue as [FakeRealEstateProjectRepository]
/// (single-tenant scope for Phase 2 — a real cross-tenant marketplace is
/// Phase 3) rather than duplicating it, and seeds one demo booking +
/// installment plan against that catalogue's verified land-share project so
/// "My Properties" is fully demoable with no backend.
class FakeBuyerRepository implements BuyerRepository {
  FakeBuyerRepository(this._projects);

  final RealEstateProjectRepository _projects;
  final Set<String> _savedIds = {};

  static final DateTime _startDate = DateTime.now().subtract(
    const Duration(days: 90),
  );

  static const _demoBooking = RealEstateBooking(
    id: 'bk-buyer-1',
    leadId: 'lead-buyer-1',
    leadName: 'Tanvir Ahmed',
    projectId: 'rp1',
    projectTitle: 'Diabari Green Residency (Land-share)',
    unitId: 'u1',
    unitName: 'Share #1',
    acceptedOfferId: 'off-buyer-1',
    agreedPrice: 3200000,
    status: RealEstateBookingStatus.booked,
  );

  late final InstallmentPlan _demoPlan = InstallmentPlan(
    id: 'ip-buyer-1',
    bookingId: _demoBooking.id,
    downPaymentAmount: _demoBooking.agreedPrice * 0.3,
    installmentCount: 12,
    frequency: InstallmentFrequency.monthly,
    startDate: _startDate,
    installments: _buildInstallments(),
    createdAt: _startDate,
  );

  static List<Installment> _buildInstallments() {
    final financed = _demoBooking.agreedPrice * 0.7;
    final amounts = splitInstallmentAmounts(financed, 12);
    return [
      for (var i = 0; i < amounts.length; i++)
        Installment(
          id: 'ip-buyer-1-inst-${i + 1}',
          installmentPlanId: 'ip-buyer-1',
          sequence: i + 1,
          amount: amounts[i],
          dueDate: DateTime(_startDate.year, _startDate.month + i + 1),
          // The first three months are already settled; the rest are still
          // scheduled — a mix that exercises the "next due" and overdue UI.
          status: i < 3 ? InstallmentStatus.paid : InstallmentStatus.pending,
        ),
    ];
  }

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  bool _matches(RealEstateProject p, String q) {
    final loc = p.location;
    final haystack = [
      p.title,
      loc?.division,
      loc?.district,
      loc?.area,
      loc?.sector,
      loc?.road,
      ...(loc?.landmarks ?? const []),
    ].whereType<String>().join(' ').toLowerCase();
    return haystack.contains(q.toLowerCase());
  }

  @override
  Future<Result<List<RealEstateProject>>> browseVerified({
    String? query,
  }) async {
    final result = await _projects.list();
    return result.map((all) {
      final verified = all.where((p) => p.status == ProjectStatus.verified);
      final q = query?.trim() ?? '';
      if (q.isEmpty) return verified.toList(growable: false);
      return verified.where((p) => _matches(p, q)).toList(growable: false);
    });
  }

  @override
  Future<Result<List<String>>> savedProjectIds() =>
      _delayed(Result.ok(_savedIds.toList(growable: false)));

  @override
  Future<Result<void>> saveProject(String projectId) {
    _savedIds.add(projectId);
    return _delayed(const Result.ok(null));
  }

  @override
  Future<Result<void>> unsaveProject(String projectId) {
    _savedIds.remove(projectId);
    return _delayed(const Result.ok(null));
  }

  @override
  Future<Result<List<RealEstateBooking>>> myBookings() =>
      _delayed(const Result.ok([_demoBooking]));

  @override
  Future<Result<InstallmentPlan>> installmentPlanFor(String bookingId) {
    if (bookingId != _demoBooking.id) {
      return _delayed(const Result.err(NotFoundFailure()));
    }
    return _delayed(Result.ok(_demoPlan));
  }
}
