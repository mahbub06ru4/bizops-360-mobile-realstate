import 'package:equatable/equatable.dart';

import 'unit_media.dart';
import 'unit_price.dart';

enum UnitStatus { available, reserved, sold }

/// Compass orientation a unit faces (backend `UnitFacing` enum). Nullable on
/// [Unit] — not every unit records a facing.
enum UnitFacing {
  north,
  south,
  east,
  west,
  northeast,
  northwest,
  southeast,
  southwest,
}

/// One sellable unit inside a [Building] (or standalone, for a plot-only
/// land-share project). Mirrors the backend's `UnitResource` field-for-field
/// — there is no per-unit "type"; apartment/land_share/commercial belongs to
/// the parent `RealEstateProject`. Roadmap §5 `units` + `unit_media` +
/// `unit_prices`.
class Unit extends Equatable {
  const Unit({
    required this.id,
    required this.buildingId,
    required this.unitNumber,
    required this.sizeSqft,
    this.floor,
    this.bedrooms,
    this.bathrooms,
    this.facing,
    this.parkingSpaces,
    this.status = UnitStatus.available,
    this.media = const [],
    this.prices = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String buildingId;

  /// e.g. "A-501", "Plot 12", "Share #7".
  final String unitNumber;
  final int? floor;
  final num sizeSqft;
  final int? bedrooms;
  final int? bathrooms;
  final UnitFacing? facing;
  final int? parkingSpaces;
  final UnitStatus status;
  final List<UnitMedia> media;
  final List<UnitPrice> prices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Unit copyWith({
    String? unitNumber,
    int? floor,
    num? sizeSqft,
    int? bedrooms,
    int? bathrooms,
    UnitFacing? facing,
    int? parkingSpaces,
    UnitStatus? status,
    List<UnitMedia>? media,
    List<UnitPrice>? prices,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Unit(
    id: id,
    buildingId: buildingId,
    unitNumber: unitNumber ?? this.unitNumber,
    floor: floor ?? this.floor,
    sizeSqft: sizeSqft ?? this.sizeSqft,
    bedrooms: bedrooms ?? this.bedrooms,
    bathrooms: bathrooms ?? this.bathrooms,
    facing: facing ?? this.facing,
    parkingSpaces: parkingSpaces ?? this.parkingSpaces,
    status: status ?? this.status,
    media: media ?? this.media,
    prices: prices ?? this.prices,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    buildingId,
    unitNumber,
    floor,
    sizeSqft,
    bedrooms,
    bathrooms,
    facing,
    parkingSpaces,
    status,
    media,
    prices,
    createdAt,
    updatedAt,
  ];
}
