import 'package:equatable/equatable.dart';

/// A photo (Phase 0) attached to a [Unit]. Video/floor-plan document types are
/// a later phase; `kind` is a free-text hint (`photo`, `floor_plan`) so the
/// backend can extend it without a mobile release.
class UnitMedia extends Equatable {
  const UnitMedia({
    required this.id,
    required this.url,
    this.caption,
    this.isPrimary = false,
  });

  final String id;
  final String url;
  final String? caption;
  final bool isPrimary;

  @override
  List<Object?> get props => [id, url, caption, isPrimary];
}
