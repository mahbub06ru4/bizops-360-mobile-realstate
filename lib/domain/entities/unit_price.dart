import 'package:equatable/equatable.dart';

/// One priced line on a [Unit] — e.g. "Total price", "Per katha" for a
/// land-share unit, "Per sqft" for an apartment. BDT.
class UnitPrice extends Equatable {
  const UnitPrice({
    required this.id,
    required this.label,
    required this.amount,
  });

  final String id;
  final String label;

  /// BDT.
  final num amount;

  @override
  List<Object?> get props => [id, label, amount];
}
