import 'package:equatable/equatable.dart';

/// Visa case pipeline (spec §5.1).
enum VisaStage {
  caseOpened,
  docsRequired,
  docsCollected,
  submitted,
  processing,
  approved,
  rejected,
}

class VisaDoc extends Equatable {
  const VisaDoc({required this.name, this.collected = false});

  final String name;
  final bool collected;

  VisaDoc toggle() => VisaDoc(name: name, collected: !collected);

  @override
  List<Object?> get props => [name, collected];
}

class VisaApplication extends Equatable {
  const VisaApplication({
    required this.id,
    required this.travellerName,
    required this.country,
    required this.category,
    required this.stage,
    required this.docs,
    this.submittedAt,
    this.decisionAt,
  });

  final String id;
  final String travellerName;
  final String country;
  final String category;
  final VisaStage stage;
  final List<VisaDoc> docs;
  final DateTime? submittedAt;
  final DateTime? decisionAt;

  int get docsCollected => docs.where((d) => d.collected).length;
  bool get allDocsCollected => docs.isNotEmpty && docsCollected == docs.length;
  double get docProgress => docs.isEmpty ? 0 : docsCollected / docs.length;

  bool get isDecided =>
      stage == VisaStage.approved || stage == VisaStage.rejected;

  VisaApplication copyWith({
    VisaStage? stage,
    List<VisaDoc>? docs,
    DateTime? submittedAt,
    DateTime? decisionAt,
  }) => VisaApplication(
    id: id,
    travellerName: travellerName,
    country: country,
    category: category,
    stage: stage ?? this.stage,
    docs: docs ?? this.docs,
    submittedAt: submittedAt ?? this.submittedAt,
    decisionAt: decisionAt ?? this.decisionAt,
  );

  @override
  List<Object?> get props => [
    id,
    travellerName,
    country,
    category,
    stage,
    docs,
    submittedAt,
    decisionAt,
  ];
}
