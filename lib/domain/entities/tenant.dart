import 'package:equatable/equatable.dart';

class Tenant extends Equatable {
  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    this.industry,
  });

  final int id;
  final String name;
  final String slug;

  /// `travel` | `real_estate` | `consultancy` | null. Drives which industry
  /// module (and nav tab) the app exposes.
  final String? industry;

  bool get isTravel => industry == 'travel';

  @override
  List<Object?> get props => [id, name, slug, industry];
}
