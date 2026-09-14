import 'package:equatable/equatable.dart';

import 'unit.dart';

/// One building inside a [RealEstateProject] (roadmap §5 `buildings`). A
/// pure land-share project may have zero buildings and sell [Unit]s directly.
class Building extends Equatable {
  const Building({
    required this.id,
    required this.name,
    required this.floors,
    this.unitsPerFloor,
    this.units = const [],
  });

  final String id;
  final String name;
  final int floors;
  final int? unitsPerFloor;
  final List<Unit> units;

  Building copyWith({
    String? name,
    int? floors,
    int? unitsPerFloor,
    List<Unit>? units,
  }) => Building(
    id: id,
    name: name ?? this.name,
    floors: floors ?? this.floors,
    unitsPerFloor: unitsPerFloor ?? this.unitsPerFloor,
    units: units ?? this.units,
  );

  @override
  List<Object?> get props => [id, name, floors, unitsPerFloor, units];
}
