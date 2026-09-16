import '../../domain/entities/amenity.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/payment_plan.dart';
import '../../domain/entities/project_location.dart';
import '../../domain/entities/project_pricing.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_media.dart';
import '../../domain/entities/unit_price.dart';

/// JSON ↔ entity mapping for the real-estate module. The data source has
/// already unwrapped the envelope, so these see the inner resource objects.

const Map<String, ProjectType> _typeFromApi = {
  'land_share': ProjectType.landShare,
  'apartment': ProjectType.apartment,
  'commercial': ProjectType.commercial,
};

const Map<ProjectType, String> projectTypeToApi = {
  ProjectType.landShare: 'land_share',
  ProjectType.apartment: 'apartment',
  ProjectType.commercial: 'commercial',
};

const Map<String, ProjectStatus> _statusFromApi = {
  'draft': ProjectStatus.draft,
  'submitted': ProjectStatus.submitted,
  'pending': ProjectStatus.submitted,
  'verified': ProjectStatus.verified,
  'approved': ProjectStatus.verified,
  'rejected': ProjectStatus.rejected,
};

const Map<String, UnitStatus> _unitStatusFromApi = {
  'available': UnitStatus.available,
  'reserved': UnitStatus.reserved,
  'sold': UnitStatus.sold,
};

const Map<String, UnitFacing> _unitFacingFromApi = {
  'north': UnitFacing.north,
  'south': UnitFacing.south,
  'east': UnitFacing.east,
  'west': UnitFacing.west,
  'northeast': UnitFacing.northeast,
  'northwest': UnitFacing.northwest,
  'southeast': UnitFacing.southeast,
  'southwest': UnitFacing.southwest,
};

const Map<UnitFacing, String> unitFacingToApi = {
  UnitFacing.north: 'north',
  UnitFacing.south: 'south',
  UnitFacing.east: 'east',
  UnitFacing.west: 'west',
  UnitFacing.northeast: 'northeast',
  UnitFacing.northwest: 'northwest',
  UnitFacing.southeast: 'southeast',
  UnitFacing.southwest: 'southwest',
};

num _num(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

DateTime? _date(dynamic v) {
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}

List<Map<String, dynamic>> _list(dynamic v) => v is List
    ? v
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false)
    : const [];

ProjectLocation projectLocationFromJson(Map<String, dynamic> json) {
  return ProjectLocation(
    division: json['division'] as String? ?? '',
    district: json['district'] as String? ?? '',
    area: json['area'] as String? ?? '',
    sector: json['sector'] as String?,
    road: json['road'] as String?,
    landmarks:
        (json['landmarks'] as List?)?.whereType<String>().toList() ?? const [],
  );
}

Map<String, dynamic> projectLocationToJson(ProjectLocation l) => {
  'division': l.division,
  'district': l.district,
  'area': l.area,
  if (l.sector != null) 'sector': l.sector,
  if (l.road != null) 'road': l.road,
  'landmarks': l.landmarks,
};

UnitMedia unitMediaFromJson(Map<String, dynamic> json) => UnitMedia(
  id: json['id'].toString(),
  url: json['url'] as String? ?? '',
  caption: json['caption'] as String?,
  isPrimary: json['is_primary'] == true,
);

UnitPrice unitPriceFromJson(Map<String, dynamic> json) => UnitPrice(
  id: json['id'].toString(),
  label: json['label'] as String? ?? '',
  amount: _num(json['amount']),
);

Unit unitFromJson(Map<String, dynamic> json) => Unit(
  id: json['id'].toString(),
  buildingId: json['building_id']?.toString() ?? '',
  unitNumber: json['unit_number'] as String? ?? '',
  sizeSqft: _num(json['size_sqft']),
  floor: (json['floor'] as num?)?.toInt(),
  bedrooms: (json['bedrooms'] as num?)?.toInt(),
  bathrooms: (json['bathrooms'] as num?)?.toInt(),
  facing: _unitFacingFromApi[json['facing']],
  parkingSpaces: (json['parking_spaces'] as num?)?.toInt(),
  status: _unitStatusFromApi[json['status']] ?? UnitStatus.available,
  media: _list(json['media']).map(unitMediaFromJson).toList(growable: false),
  prices: _list(json['prices']).map(unitPriceFromJson).toList(growable: false),
  createdAt: _date(json['created_at']),
  updatedAt: _date(json['updated_at']),
);

/// Payload for `POST/PUT` unit endpoints — matches `UnitRequest`'s
/// validation rules (`unit_number`, `floor`, `size_sqft` required;
/// `bedrooms`/`bathrooms`/`facing` nullable; `parking_spaces` optional).
Map<String, dynamic> unitToJson({
  required String unitNumber,
  required int floor,
  required num sizeSqft,
  int? bedrooms,
  int? bathrooms,
  UnitFacing? facing,
  int? parkingSpaces,
}) => {
  'unit_number': unitNumber,
  'floor': floor,
  'size_sqft': sizeSqft,
  'bedrooms': ?bedrooms,
  'bathrooms': ?bathrooms,
  'facing': ?(facing == null ? null : unitFacingToApi[facing]),
  'parking_spaces': ?parkingSpaces,
};

Building buildingFromJson(Map<String, dynamic> json) => Building(
  id: json['id'].toString(),
  name: json['name'] as String? ?? '',
  floors: (json['floors'] as num?)?.toInt() ?? 0,
  unitsPerFloor: (json['units_per_floor'] as num?)?.toInt(),
  units: _list(json['units']).map(unitFromJson).toList(growable: false),
);

Amenity amenityFromJson(Map<String, dynamic> json) => Amenity(
  id: json['id'].toString(),
  name: json['name'] as String? ?? '',
  icon: json['icon'] as String?,
  available: json['available'] != false,
);

ProjectPricing projectPricingFromJson(Map<String, dynamic> json) =>
    ProjectPricing(
      landCost: _num(json['land_cost']),
      constructionCost: _num(json['construction_cost']),
      consultancyCost: _num(json['consultancy_cost']),
    );

Map<String, dynamic> projectPricingToJson(ProjectPricing p) => {
  'land_cost': p.landCost,
  'construction_cost': p.constructionCost,
  'consultancy_cost': p.consultancyCost,
};

PaymentPlan paymentPlanFromJson(Map<String, dynamic> json) => PaymentPlan(
  id: json['id'].toString(),
  name: json['name'] as String? ?? '',
  downPaymentPercent: _num(json['down_payment_percent']),
  installmentCount: (json['installment_count'] as num?)?.toInt() ?? 0,
  installmentAmount: json['installment_amount'] == null
      ? null
      : _num(json['installment_amount']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> paymentPlanToJson(PaymentPlan p) => {
  'name': p.name,
  'down_payment_percent': p.downPaymentPercent,
  'installment_count': p.installmentCount,
  if (p.installmentAmount != null) 'installment_amount': p.installmentAmount,
  if (p.notes != null) 'notes': p.notes,
};

RealEstateProject realEstateProjectFromJson(Map<String, dynamic> json) {
  final location = json['location'];
  final pricing = json['pricing'];
  final contact = json['contact'];

  return RealEstateProject(
    id: json['id'].toString(),
    title: json['title'] as String? ?? '',
    type: _typeFromApi[json['type']] ?? ProjectType.apartment,
    status: _statusFromApi[json['status']] ?? ProjectStatus.draft,
    description: json['description'] as String?,
    location: location is Map
        ? projectLocationFromJson(location.cast<String, dynamic>())
        : null,
    buildings: _list(
      json['buildings'],
    ).map(buildingFromJson).toList(growable: false),
    amenities: _list(
      json['amenities'],
    ).map(amenityFromJson).toList(growable: false),
    pricing: pricing is Map
        ? projectPricingFromJson(pricing.cast<String, dynamic>())
        : null,
    paymentPlans: _list(
      json['payment_plans'],
    ).map(paymentPlanFromJson).toList(growable: false),
    contactName: contact is Map
        ? contact['name'] as String?
        : json['contact_name'] as String?,
    contactPhone: contact is Map
        ? contact['phone'] as String?
        : json['contact_phone'] as String?,
    createdAt: _date(json['created_at']),
    developerName:
        json['developer_name'] as String? ??
        (json['tenant'] is Map
            ? (json['tenant'] as Map)['name'] as String?
            : null),
  );
}
