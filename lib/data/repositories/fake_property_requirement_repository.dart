import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/property_match.dart';
import '../../domain/entities/property_requirement.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_price.dart';
import '../../domain/repositories/property_requirement_repository.dart';

/// In-memory requirements + rule-based matching for UI-first development.
/// Seeded so a lead already has a matched requirement — project/unit names
/// mirror [FakeRealEstateProjectRepository]'s demo catalogue (`rp1`
/// Diabari land-share, `rp2` Khulshi Heights) without depending on that
/// repository directly.
class FakePropertyRequirementRepository
    implements PropertyRequirementRepository {
  FakePropertyRequirementRepository()
    : _items = _seedRequirements(),
      _matches = _seedMatches();

  List<PropertyRequirement> _items;
  List<PropertyMatch> _matches;
  var _nextRequirementId = 200;
  var _nextMatchId = 400;

  static DateTime _ago(int days) =>
      DateTime.now().subtract(Duration(days: days));

  static List<PropertyRequirement> _seedRequirements() => [
    PropertyRequirement(
      id: 'req1',
      leadId: 'c2',
      leadName: 'Nusrat Jahan',
      budgetMin: 12000000,
      budgetMax: 16000000,
      preferredLocations: 'Khulshi, Chattogram',
      unitType: ProjectType.apartment,
      bedroomsMin: 3,
      notes: '3-4 bedroom, near a medical college.',
      createdAt: _ago(7),
    ),
  ];

  static const _unitA3B = Unit(
    id: 'u3',
    buildingId: 'b2',
    unitNumber: 'A-3B',
    sizeSqft: 1650,
    floor: 3,
    bedrooms: 3,
    bathrooms: 3,
    facing: UnitFacing.southeast,
    parkingSpaces: 1,
    prices: [UnitPrice(id: 'up3', label: 'Total price', amount: 14500000)],
  );

  static const _unitShare1 = Unit(
    id: 'u1',
    buildingId: 'b1',
    unitNumber: 'Share #1',
    sizeSqft: 720,
    facing: UnitFacing.south,
    prices: [UnitPrice(id: 'up1', label: 'Per katha', amount: 3200000)],
  );

  static const _unitA4B = Unit(
    id: 'u4',
    buildingId: 'b2',
    unitNumber: 'A-4B',
    sizeSqft: 1680,
    floor: 4,
    bedrooms: 4,
    bathrooms: 3,
    facing: UnitFacing.northwest,
    parkingSpaces: 1,
    prices: [UnitPrice(id: 'up4', label: 'Total price', amount: 14800000)],
  );

  static List<PropertyMatch> _seedMatches() => [
    PropertyMatch(
      id: 'match1',
      requirementId: 'req1',
      unitId: 'u3',
      matchScore: 92,
      status: PropertyMatchStatus.suggested,
      unit: _unitA3B,
      createdAt: _ago(6),
    ),
    PropertyMatch(
      id: 'match2',
      requirementId: 'req1',
      unitId: 'u1',
      matchScore: 61,
      status: PropertyMatchStatus.suggested,
      unit: _unitShare1,
      createdAt: _ago(6),
    ),
    PropertyMatch(
      id: 'match3',
      requirementId: 'req1',
      unitId: 'u4',
      matchScore: 15,
      status: PropertyMatchStatus.suggested,
      unit: _unitA4B,
      createdAt: _ago(6),
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  @override
  Future<Result<List<PropertyRequirement>>> forLead(String leadId) => _delayed(
    Result.ok(List.unmodifiable(_items.where((r) => r.leadId == leadId))),
  );

  @override
  Future<Result<PropertyRequirement>> create({
    required String leadId,
    required String leadName,
    num? budgetMin,
    num? budgetMax,
    String? preferredLocations,
    ProjectType? unitType,
    int? bedroomsMin,
    RequirementPurpose? purpose,
    String? notes,
  }) {
    final req = PropertyRequirement(
      id: 'req${_nextRequirementId++}',
      leadId: leadId,
      leadName: leadName,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      preferredLocations: preferredLocations,
      unitType: unitType,
      bedroomsMin: bedroomsMin,
      purpose: purpose ?? RequirementPurpose.buy,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _items = [req, ..._items];
    return _delayed(Result.ok(req));
  }

  @override
  Future<Result<List<PropertyMatch>>> match(String requirementId) {
    final req = _items.where((r) => r.id == requirementId).firstOrNull;
    if (req == null) return _delayed(const Result.err(NotFoundFailure()));

    // Rule-based filter over a tiny in-memory catalogue mirroring the
    // project fake repo's seed — good enough to demo the pipeline offline;
    // a real backend would filter the actual project/unit tables.
    const catalogue = [
      (
        unit: _unitA3B,
        division: 'Chattogram',
        projectType: ProjectType.apartment,
      ),
      (
        unit: _unitShare1,
        division: 'Dhaka',
        projectType: ProjectType.landShare,
      ),
    ];

    final generated = <PropertyMatch>[];
    for (final entry in catalogue) {
      var score = 50;
      if (req.unitType == null || req.unitType == entry.projectType) {
        score += 20;
      }
      if (req.preferredLocations == null ||
          req.preferredLocations!.contains(entry.division)) {
        score += 15;
      }
      final price = entry.unit.prices.isEmpty
          ? 0
          : entry.unit.prices.first.amount;
      final minB = req.budgetMin ?? 0;
      final maxB = req.budgetMax ?? double.maxFinite;
      if (price >= minB && price <= maxB) score += 15;
      generated.add(
        PropertyMatch(
          id: 'match${_nextMatchId++}',
          requirementId: requirementId,
          unitId: entry.unit.id,
          matchScore: score.clamp(0, 100),
          status: PropertyMatchStatus.suggested,
          unit: entry.unit,
          createdAt: DateTime.now(),
        ),
      );
    }
    generated.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    _matches = [...generated, ..._matches];
    return _delayed(Result.ok(List.unmodifiable(generated)));
  }

  @override
  Future<Result<List<PropertyMatch>>> matchesFor(String requirementId) =>
      _delayed(
        Result.ok(
          List.unmodifiable(
            _matches.where((m) => m.requirementId == requirementId).toList()
              ..sort((a, b) => b.matchScore.compareTo(a.matchScore)),
          ),
        ),
      );
}
