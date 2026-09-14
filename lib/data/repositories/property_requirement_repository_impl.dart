import '../../core/error/result.dart';
import '../../domain/entities/property_match.dart';
import '../../domain/entities/property_requirement.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/repositories/property_requirement_repository.dart';
import '../datasources/real_estate_pipeline_remote_datasource.dart';
import '../models/real_estate_pipeline_mappers.dart';
import 'remote_guard.dart';

class PropertyRequirementRepositoryImpl
    implements PropertyRequirementRepository {
  PropertyRequirementRepositoryImpl(this._remote);

  final RealEstatePipelineRemoteDataSource _remote;

  @override
  Future<Result<List<PropertyRequirement>>> forLead(String leadId) {
    return guardRequest(
      () async => (await _remote.requirementsForLead(
        leadId,
      )).map(propertyRequirementFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<PropertyRequirement>> create({
    required String leadId,
    required String leadName,
    num? budgetMin,
    num? budgetMax,
    String? preferredLocations,
    ProjectType? unitType,
    int? bedroomsMin,
    RequirementPurpose? purpose,
    String? notes,
  }) {
    return guardRequest(() async {
      final body = propertyRequirementToJson(
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        preferredLocations: preferredLocations,
        unitType: unitType,
        bedroomsMin: bedroomsMin,
        purpose: purpose,
        notes: notes,
      );
      return propertyRequirementFromJson(
        await _remote.createRequirement(leadId, body),
      );
    });
  }

  @override
  Future<Result<List<PropertyMatch>>> match(String requirementId) {
    return guardRequest(
      () async => (await _remote.matchRequirement(
        requirementId,
      )).map(propertyMatchFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<List<PropertyMatch>>> matchesFor(String requirementId) {
    return guardRequest(
      () async => (await _remote.matchesFor(
        requirementId,
      )).map(propertyMatchFromJson).toList(growable: false),
    );
  }
}
