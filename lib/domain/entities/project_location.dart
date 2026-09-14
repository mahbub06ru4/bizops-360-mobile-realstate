import 'package:equatable/equatable.dart';

/// Bangladesh administrative + landmark location for a [RealEstateProject]
/// (roadmap §5 `project_locations`): division/district/area/sector/road, plus
/// free-text nearby landmarks used for later landmark-based search (Phase 2+).
class ProjectLocation extends Equatable {
  const ProjectLocation({
    required this.division,
    required this.district,
    required this.area,
    this.sector,
    this.road,
    this.landmarks = const [],
  });

  final String division;
  final String district;
  final String area;
  final String? sector;
  final String? road;
  final List<String> landmarks;

  String get shortLabel => [
    if (sector != null && sector!.isNotEmpty) sector,
    area,
    district,
  ].where((s) => s != null && s.isNotEmpty).join(', ');

  ProjectLocation copyWith({
    String? division,
    String? district,
    String? area,
    String? sector,
    String? road,
    List<String>? landmarks,
  }) => ProjectLocation(
    division: division ?? this.division,
    district: district ?? this.district,
    area: area ?? this.area,
    sector: sector ?? this.sector,
    road: road ?? this.road,
    landmarks: landmarks ?? this.landmarks,
  );

  @override
  List<Object?> get props => [
    division,
    district,
    area,
    sector,
    road,
    landmarks,
  ];
}
