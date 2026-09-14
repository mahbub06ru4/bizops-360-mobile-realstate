import 'package:equatable/equatable.dart';

/// Project-level cost breakdown (roadmap §5 `project_pricing`): land +
/// construction + consultancy roll up to an estimated total. All BDT.
class ProjectPricing extends Equatable {
  const ProjectPricing({
    this.landCost = 0,
    this.constructionCost = 0,
    this.consultancyCost = 0,
  });

  final num landCost;
  final num constructionCost;
  final num consultancyCost;

  num get estimatedTotal => landCost + constructionCost + consultancyCost;

  ProjectPricing copyWith({
    num? landCost,
    num? constructionCost,
    num? consultancyCost,
  }) => ProjectPricing(
    landCost: landCost ?? this.landCost,
    constructionCost: constructionCost ?? this.constructionCost,
    consultancyCost: consultancyCost ?? this.consultancyCost,
  );

  @override
  List<Object?> get props => [landCost, constructionCost, consultancyCost];
}
