import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/payment_plan.dart';
import '../../domain/entities/project_location.dart';
import '../../domain/entities/project_pricing.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_media.dart';
import '../../domain/entities/unit_price.dart';
import '../../domain/repositories/real_estate_project_repository.dart';

/// In-memory real-estate projects for UI-first development
/// (`Env.useFakeData`) — seeded with realistic Bangladeshi demo projects so
/// the Post Project wizard and the seller/buyer detail screen are fully
/// demoable with no backend, per the mobile app's "UI-first" rule.
class FakeRealEstateProjectRepository implements RealEstateProjectRepository {
  FakeRealEstateProjectRepository() : _items = _seed();

  List<RealEstateProject> _items;
  var _nextProjectId = 300;
  var _nextBuildingId = 500;
  var _nextUnitId = 700;
  var _nextAmenityId = 900;
  var _nextPriceId = 1100;
  var _nextPlanId = 1300;
  var _nextMediaId = 1500;

  static List<RealEstateProject> _seed() => [
    // A land-share project — Uttara, Dhaka. The roadmap's own worked example
    // (§92: "the Uttara Diabari example").
    RealEstateProject(
      id: 'rp1',
      title: 'Diabari Green Residency (Land-share)',
      type: ProjectType.landShare,
      status: ProjectStatus.verified,
      description:
          'A 10-katha land-share development at Diabari, Uttara — shares sold '
          'individually, each convertible to a unit once construction starts.',
      location: const ProjectLocation(
        division: 'Dhaka',
        district: 'Dhaka',
        area: 'Uttara',
        sector: 'Sector 18',
        road: 'Road 5',
        landmarks: ['Diabari Metro Station', 'Uttara Sector 18 Bridge'],
      ),
      buildings: [
        Building(
          id: 'b1',
          name: 'Land parcel',
          floors: 1,
          units: [
            Unit(
              id: 'u1',
              buildingId: 'b1',
              unitNumber: 'Share #1',
              sizeSqft: 720,
              facing: UnitFacing.south,
              parkingSpaces: 0,
              prices: [
                const UnitPrice(id: 'pr1', label: 'Per katha', amount: 3200000),
              ],
              media: [
                const UnitMedia(
                  id: 'm1',
                  url: 'https://picsum.photos/seed/diabari1/640/480',
                  caption: 'Site — road-facing corner',
                  isPrimary: true,
                ),
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 40)),
            ),
            Unit(
              id: 'u2',
              buildingId: 'b1',
              unitNumber: 'Share #2',
              sizeSqft: 720,
              status: UnitStatus.reserved,
              facing: UnitFacing.north,
              parkingSpaces: 0,
              prices: [
                const UnitPrice(id: 'pr2', label: 'Per katha', amount: 3200000),
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 40)),
            ),
          ],
        ),
      ],
      amenities: const [
        Amenity(id: 'a1', name: 'Boundary wall', icon: 'security'),
        Amenity(id: 'a2', name: 'Internal road', icon: 'parking'),
      ],
      pricing: const ProjectPricing(
        landCost: 32000000,
        consultancyCost: 600000,
      ),
      paymentPlans: const [
        PaymentPlan(
          id: 'pp1',
          name: 'Standard',
          downPaymentPercent: 30,
          installmentCount: 12,
          notes: 'Monthly installments over one year.',
        ),
      ],
      contactName: 'Rafiqul Islam',
      contactPhone: '+8801711223344',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),

    // An apartment project — Khulshi, Chattogram.
    RealEstateProject(
      id: 'rp2',
      title: 'Khulshi Heights',
      type: ProjectType.apartment,
      status: ProjectStatus.submitted,
      description:
          '8-storey residential apartment complex overlooking Khulshi hills, '
          'Chattogram — 3 & 4 bedroom units.',
      location: const ProjectLocation(
        division: 'Chattogram',
        district: 'Chattogram',
        area: 'Khulshi',
        sector: 'Block A',
        road: 'CDA Avenue',
        landmarks: ['Khulshi Park', 'Chattogram Medical College'],
      ),
      buildings: [
        Building(
          id: 'b2',
          name: 'Tower A',
          floors: 8,
          unitsPerFloor: 2,
          units: [
            Unit(
              id: 'u3',
              buildingId: 'b2',
              unitNumber: 'A-3B',
              sizeSqft: 1650,
              floor: 3,
              bedrooms: 3,
              bathrooms: 3,
              facing: UnitFacing.southeast,
              parkingSpaces: 1,
              prices: [
                const UnitPrice(
                  id: 'pr3',
                  label: 'Total price',
                  amount: 14500000,
                ),
                const UnitPrice(id: 'pr4', label: 'Per sqft', amount: 8788),
              ],
              media: [
                const UnitMedia(
                  id: 'm2',
                  url: 'https://picsum.photos/seed/khulshi1/640/480',
                  caption: 'Living room render',
                  isPrimary: true,
                ),
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 12)),
            ),
            Unit(
              id: 'u4',
              buildingId: 'b2',
              unitNumber: 'A-4B',
              sizeSqft: 1650,
              floor: 4,
              bedrooms: 4,
              bathrooms: 3,
              facing: UnitFacing.northwest,
              parkingSpaces: 1,
              status: UnitStatus.sold,
              prices: [
                const UnitPrice(
                  id: 'pr5',
                  label: 'Total price',
                  amount: 14800000,
                ),
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 12)),
            ),
          ],
        ),
      ],
      amenities: const [
        Amenity(id: 'a3', name: 'Lift', icon: 'lift'),
        Amenity(id: 'a4', name: 'Generator backup', icon: 'generator'),
        Amenity(id: 'a5', name: 'Car parking', icon: 'parking'),
        Amenity(id: 'a6', name: '24/7 security', icon: 'security'),
        Amenity(id: 'a7', name: 'Community hall', icon: 'community_hall'),
      ],
      pricing: const ProjectPricing(
        landCost: 90000000,
        constructionCost: 220000000,
        consultancyCost: 8000000,
      ),
      paymentPlans: const [
        PaymentPlan(
          id: 'pp2',
          name: 'Standard 3-year',
          downPaymentPercent: 20,
          installmentCount: 36,
          installmentAmount: 322000,
        ),
      ],
      contactName: 'Farhana Chowdhury',
      contactPhone: '+8801819887766',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),

    // A draft the seller hasn't finished / submitted yet — Gazipur.
    RealEstateProject(
      id: 'rp3',
      title: 'Konabari Commercial Plaza',
      type: ProjectType.commercial,
      status: ProjectStatus.draft,
      description: 'Ground + 4 commercial plaza on the Dhaka-Tangail highway.',
      location: const ProjectLocation(
        division: 'Dhaka',
        district: 'Gazipur',
        area: 'Konabari',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  RealEstateProject? _find(String id) =>
      _items.where((p) => p.id == id).firstOrNull;

  Result<RealEstateProject> _replace(RealEstateProject p) {
    _items = [
      for (final x in _items)
        if (x.id == p.id) p else x,
    ];
    return Result.ok(p);
  }

  Result<RealEstateProject> _mutate(
    String id,
    RealEstateProject Function(RealEstateProject p) update,
  ) {
    final p = _find(id);
    if (p == null) return const Result.err(NotFoundFailure());
    return _replace(update(p));
  }

  @override
  Future<Result<List<RealEstateProject>>> list() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<RealEstateProject>> getById(String id) {
    final p = _find(id);
    return _delayed(
      p == null ? const Result.err(NotFoundFailure()) : Result.ok(p),
    );
  }

  @override
  Future<Result<RealEstateProject>> create({
    required String title,
    required ProjectType type,
    String? description,
  }) {
    final p = RealEstateProject(
      id: 'rp${_nextProjectId++}',
      title: title,
      type: type,
      status: ProjectStatus.draft,
      description: description,
      createdAt: DateTime.now(),
    );
    _items = [p, ..._items];
    return _delayed(Result.ok(p));
  }

  @override
  Future<Result<RealEstateProject>> update(
    String id, {
    String? title,
    String? description,
    String? contactName,
    String? contactPhone,
  }) {
    return _delayed(
      _mutate(
        id,
        (p) => p.copyWith(
          title: title,
          description: description,
          contactName: contactName,
          contactPhone: contactPhone,
        ),
      ),
    );
  }

  @override
  Future<Result<RealEstateProject>> submitForVerification(String id) {
    final p = _find(id);
    if (p == null) return _delayed(const Result.err(NotFoundFailure()));
    if (!p.canSubmit) {
      return _delayed(
        const Result.err(
          ValidationFailure(
            'Add a location before submitting for verification.',
            {
              'location': [
                'Add a location before submitting for verification.',
              ],
            },
          ),
        ),
      );
    }
    return _delayed(_replace(p.copyWith(status: ProjectStatus.submitted)));
  }

  @override
  Future<Result<RealEstateProject>> addBuilding(
    String projectId, {
    required String name,
    required int floors,
    int? unitsPerFloor,
  }) {
    final building = Building(
      id: 'b${_nextBuildingId++}',
      name: name,
      floors: floors,
      unitsPerFloor: unitsPerFloor,
    );
    return _delayed(
      _mutate(
        projectId,
        (p) => p.copyWith(buildings: [...p.buildings, building]),
      ),
    );
  }

  @override
  Future<Result<RealEstateProject>> addUnit(
    String projectId,
    String buildingId, {
    required String unitNumber,
    required num sizeSqft,
    int? floor,
    int? bedrooms,
    int? bathrooms,
    UnitFacing? facing,
    int? parkingSpaces,
    num? priceAmount,
    String? priceLabel,
  }) {
    final unit = Unit(
      id: 'u${_nextUnitId++}',
      buildingId: buildingId,
      unitNumber: unitNumber,
      sizeSqft: sizeSqft,
      floor: floor,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      facing: facing,
      parkingSpaces: parkingSpaces,
      createdAt: DateTime.now(),
      prices: priceAmount == null
          ? const []
          : [
              UnitPrice(
                id: 'pr${_nextPriceId++}',
                label: priceLabel ?? 'Total price',
                amount: priceAmount,
              ),
            ],
    );
    return _delayed(
      _mutate(projectId, (p) {
        final buildings = [
          for (final b in p.buildings)
            if (b.id == buildingId)
              b.copyWith(units: [...b.units, unit])
            else
              b,
        ];
        return p.copyWith(buildings: buildings);
      }),
    );
  }

  @override
  Future<Result<RealEstateProject>> addLocation(
    String projectId, {
    required ProjectLocation location,
  }) {
    return _delayed(_mutate(projectId, (p) => p.copyWith(location: location)));
  }

  @override
  Future<Result<RealEstateProject>> addAmenity(
    String projectId, {
    required String name,
    String? icon,
  }) {
    final amenity = Amenity(id: 'a${_nextAmenityId++}', name: name, icon: icon);
    return _delayed(
      _mutate(
        projectId,
        (p) => p.copyWith(amenities: [...p.amenities, amenity]),
      ),
    );
  }

  @override
  Future<Result<RealEstateProject>> setPricing(
    String projectId, {
    required ProjectPricing pricing,
  }) {
    return _delayed(_mutate(projectId, (p) => p.copyWith(pricing: pricing)));
  }

  @override
  Future<Result<RealEstateProject>> addPaymentPlan(
    String projectId, {
    required PaymentPlan plan,
  }) {
    final withId = PaymentPlan(
      id: 'pp${_nextPlanId++}',
      name: plan.name,
      downPaymentPercent: plan.downPaymentPercent,
      installmentCount: plan.installmentCount,
      installmentAmount: plan.installmentAmount,
      notes: plan.notes,
    );
    return _delayed(
      _mutate(
        projectId,
        (p) => p.copyWith(paymentPlans: [...p.paymentPlans, withId]),
      ),
    );
  }

  @override
  Future<Result<RealEstateProject>> uploadMedia(
    String projectId,
    String unitId, {
    required String url,
    String? caption,
    bool isPrimary = false,
  }) {
    final media = UnitMedia(
      id: 'm${_nextMediaId++}',
      url: url,
      caption: caption,
      isPrimary: isPrimary,
    );
    return _delayed(
      _mutate(projectId, (p) {
        final buildings = [
          for (final b in p.buildings)
            b.copyWith(
              units: [
                for (final u in b.units)
                  if (u.id == unitId)
                    u.copyWith(media: [...u.media, media])
                  else
                    u,
              ],
            ),
        ];
        return p.copyWith(buildings: buildings);
      }),
    );
  }
}
