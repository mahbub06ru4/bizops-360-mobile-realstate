import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/project_location.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_media.dart';
import '../../domain/entities/unit_price.dart';
import '../../domain/repositories/buyer_repository.dart';
import '../../domain/repositories/real_estate_project_repository.dart';

/// In-memory [BuyerRepository] for UI-first development (`Env.useFakeData`).
/// Reads the seeded catalogue from [FakeRealEstateProjectRepository] (the
/// logged-in tenant's own projects, labelled here as developer "Greenland
/// Properties") and adds a second, wholly separate demo developer
/// ("Chattogram Nest Builders") with its own verified projects, so Browse
/// genuinely demonstrates a multi-tenant marketplace rather than one
/// tenant's catalogue (roadmap §7 Phase 3). A real cross-tenant marketplace
/// still needs the backend endpoint documented on
/// [BuyerRemoteDataSource] — this is client-side aggregation only.
class FakeBuyerRepository implements BuyerRepository {
  FakeBuyerRepository(this._projects);

  final RealEstateProjectRepository _projects;
  final Set<String> _savedIds = {};

  static const _primaryDeveloperName = 'Greenland Properties';

  /// A second demo developer, wholly distinct from the logged-in tenant's
  /// own catalogue — a Chattogram-based apartment developer with its own
  /// verified projects.
  static final List<RealEstateProject> _secondDeveloperProjects = [
    RealEstateProject(
      id: 'mp1',
      title: 'Nasirabad Skyview Apartments',
      type: ProjectType.apartment,
      status: ProjectStatus.verified,
      description:
          '6-storey residential apartment complex in Nasirabad, Chattogram — '
          '2 & 3 bedroom units with hill views.',
      developerName: 'Chattogram Nest Builders',
      location: const ProjectLocation(
        division: 'Chattogram',
        district: 'Chattogram',
        area: 'Nasirabad',
        sector: 'A/1',
        road: 'CDA Avenue Link Road',
        landmarks: ['Nasirabad Government School', 'GEC Circle'],
      ),
      buildings: [
        Building(
          id: 'mb1',
          name: 'Tower Nest-1',
          floors: 6,
          unitsPerFloor: 2,
          units: [
            Unit(
              id: 'mu1',
              buildingId: 'mb1',
              unitNumber: 'N-2A',
              sizeSqft: 1200,
              floor: 2,
              bedrooms: 2,
              bathrooms: 2,
              facing: UnitFacing.east,
              parkingSpaces: 1,
              prices: const [
                UnitPrice(id: 'mpr1', label: 'Total price', amount: 8400000),
              ],
              media: const [
                UnitMedia(
                  id: 'mm1',
                  url: 'https://picsum.photos/seed/nasirabad1/640/480',
                  caption: 'Exterior render',
                  isPrimary: true,
                ),
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 25)),
            ),
          ],
        ),
      ],
      amenities: const [
        Amenity(id: 'ma1', name: 'Rooftop garden', icon: 'community_hall'),
        Amenity(id: 'ma2', name: 'Lift', icon: 'lift'),
        Amenity(id: 'ma3', name: 'Car parking', icon: 'parking'),
      ],
      contactName: 'Shahed Kabir',
      contactPhone: '+8801777001122',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    RealEstateProject(
      id: 'mp2',
      title: 'Halishahar Riverside Residency',
      type: ProjectType.apartment,
      status: ProjectStatus.verified,
      description:
          '4-storey riverside residential building in Halishahar, '
          'Chattogram — family-sized 3 bedroom units.',
      developerName: 'Chattogram Nest Builders',
      location: const ProjectLocation(
        division: 'Chattogram',
        district: 'Chattogram',
        area: 'Halishahar',
        sector: 'Block J',
        road: 'Baraiyarhat Road',
        landmarks: ['Halishahar Housing Estate'],
      ),
      buildings: [
        const Building(
          id: 'mb2',
          name: 'Riverside Block',
          floors: 4,
          unitsPerFloor: 2,
          units: [
            Unit(
              id: 'mu2',
              buildingId: 'mb2',
              unitNumber: 'R-3A',
              sizeSqft: 1450,
              floor: 3,
              bedrooms: 3,
              bathrooms: 2,
              facing: UnitFacing.south,
              parkingSpaces: 1,
              prices: [
                UnitPrice(id: 'mpr2', label: 'Total price', amount: 9600000),
              ],
            ),
          ],
        ),
      ],
      amenities: const [
        Amenity(id: 'ma4', name: 'Generator backup', icon: 'generator'),
        Amenity(id: 'ma5', name: '24/7 security', icon: 'security'),
      ],
      contactName: 'Nasrin Sultana',
      contactPhone: '+8801777334455',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ];

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
      final primaryVerified = all
          .where((p) => p.status == ProjectStatus.verified)
          .map(
            (p) => p.developerName == null
                ? p.copyWith(developerName: _primaryDeveloperName)
                : p,
          );
      final everyone = [...primaryVerified, ..._secondDeveloperProjects];
      final q = query?.trim() ?? '';
      if (q.isEmpty) return everyone.toList(growable: false);
      return everyone.where((p) => _matches(p, q)).toList(growable: false);
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
