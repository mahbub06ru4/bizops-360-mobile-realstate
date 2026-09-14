import 'package:equatable/equatable.dart';

/// CRM pipeline stage (spec §4.4). `converted` and `lost` are terminal.
enum PipelineStage {
  newLead,
  contacted,
  interested,
  followUp,
  negotiation,
  converted,
  lost,
}

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    required this.stage,
    this.phone,
    this.email,
    this.source,
    this.note,
    this.value,
    this.lastActivityAt,
  });

  final String id;
  final String name;
  final PipelineStage stage;
  final String? phone;
  final String? email;
  final String? source;
  final String? note;

  /// Estimated deal value, in BDT.
  final num? value;
  final DateTime? lastActivityAt;

  Customer copyWith({PipelineStage? stage}) => Customer(
    id: id,
    name: name,
    stage: stage ?? this.stage,
    phone: phone,
    email: email,
    source: source,
    note: note,
    value: value,
    lastActivityAt: lastActivityAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    stage,
    phone,
    email,
    source,
    note,
    value,
    lastActivityAt,
  ];
}

/// One entry in a customer's history timeline.
class CustomerActivity extends Equatable {
  const CustomerActivity({
    required this.id,
    required this.at,
    required this.summary,
    this.detail,
  });

  final String id;
  final DateTime at;
  final String summary;
  final String? detail;

  @override
  List<Object?> get props => [id, at, summary, detail];
}
