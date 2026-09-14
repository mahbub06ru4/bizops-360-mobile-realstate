import 'package:equatable/equatable.dart';

/// A project-level amenity (lift, generator, community space, security, …).
class Amenity extends Equatable {
  const Amenity({
    required this.id,
    required this.name,
    this.icon,
    this.available = true,
  });

  final String id;
  final String name;

  /// Optional icon hint from a small fixed vocabulary the UI knows how to
  /// render (`lift`, `generator`, `security`, `parking`, `mosque`, `park`,
  /// `gym`, `community_hall`); unknown values fall back to a generic icon.
  final String? icon;
  final bool available;

  @override
  List<Object?> get props => [id, name, icon, available];
}
