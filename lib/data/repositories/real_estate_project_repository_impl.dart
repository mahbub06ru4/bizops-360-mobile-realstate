import '../../core/error/result.dart';
import '../../domain/entities/payment_plan.dart';
import '../../domain/entities/project_location.dart';
import '../../domain/entities/project_pricing.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/real_estate_project_repository.dart';
import '../datasources/real_estate_remote_datasource.dart';
import '../models/real_estate_mappers.dart';
import 'remote_guard.dart';

class RealEstateProjectRepositoryImpl implements RealEstateProjectRepository {
  RealEstateProjectRepositoryImpl(this._remote);

  final RealEstateRemoteDataSource _remote;

  @override
  Future<Result<List<RealEstateProject>>> list() {
    return guardRequest(
      () async => (await _remote.list())
          .map(realEstateProjectFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<RealEstateProject>> getById(String id) {
    return guardRequest(
      () async => realEstateProjectFromJson(await _remote.byId(id)),
    );
  }

  @override
  Future<Result<RealEstateProject>> create({
    required String title,
    required ProjectType type,
    String? description,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'title': title,
        'type': projectTypeToApi[type] ?? 'apartment',
        if (description != null && description.isNotEmpty)
          'description': description,
      };
      return realEstateProjectFromJson(await _remote.create(body));
    });
  }

  @override
  Future<Result<RealEstateProject>> update(
    String id, {
    String? title,
    String? description,
    String? contactName,
    String? contactPhone,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'title': ?title,
        'description': ?description,
        'contact_name': ?contactName,
        'contact_phone': ?contactPhone,
      };
      return realEstateProjectFromJson(await _remote.update(id, body));
    });
  }

  @override
  Future<Result<RealEstateProject>> submitForVerification(String id) {
    return guardRequest(
      () async => realEstateProjectFromJson(await _remote.submit(id)),
    );
  }

  @override
  Future<Result<RealEstateProject>> addBuilding(
    String projectId, {
    required String name,
    required int floors,
    int? unitsPerFloor,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'name': name,
        'floors': floors,
        'units_per_floor': ?unitsPerFloor,
      };
      return realEstateProjectFromJson(
        await _remote.addBuilding(projectId, body),
      );
    });
  }

  @override
  Future<Result<RealEstateProject>> addUnit(
    String projectId,
    String buildingId, {
    required String unitNumber,
    required num sizeSqft,
    int? floor,
    int? bedrooms,
    int? bathrooms,
    UnitFacing? facing,
    int? parkingSpaces,
    num? priceAmount,
    String? priceLabel,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        ...unitToJson(
          unitNumber: unitNumber,
          floor: floor ?? 0,
          sizeSqft: sizeSqft,
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          facing: facing,
          parkingSpaces: parkingSpaces,
        ),
        if (priceAmount != null)
          'prices': [
            {'label': priceLabel ?? 'Total price', 'amount': priceAmount},
          ],
      };
      return realEstateProjectFromJson(
        await _remote.addUnit(projectId, buildingId, body),
      );
    });
  }

  @override
  Future<Result<RealEstateProject>> addLocation(
    String projectId, {
    required ProjectLocation location,
  }) {
    return guardRequest(() async {
      return realEstateProjectFromJson(
        await _remote.addLocation(projectId, projectLocationToJson(location)),
      );
    });
  }

  @override
  Future<Result<RealEstateProject>> addAmenity(
    String projectId, {
    required String name,
    String? icon,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{'name': name, 'icon': ?icon};
      return realEstateProjectFromJson(
        await _remote.addAmenity(projectId, body),
      );
    });
  }

  @override
  Future<Result<RealEstateProject>> setPricing(
    String projectId, {
    required ProjectPricing pricing,
  }) {
    return guardRequest(() async {
      return realEstateProjectFromJson(
        await _remote.setPricing(projectId, projectPricingToJson(pricing)),
      );
    });
  }

  @override
  Future<Result<RealEstateProject>> addPaymentPlan(
    String projectId, {
    required PaymentPlan plan,
  }) {
    return guardRequest(() async {
      return realEstateProjectFromJson(
        await _remote.addPaymentPlan(projectId, paymentPlanToJson(plan)),
      );
    });
  }

  @override
  Future<Result<RealEstateProject>> uploadMedia(
    String projectId,
    String unitId, {
    required String url,
    String? caption,
    bool isPrimary = false,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'url': url,
        'caption': ?caption,
        'is_primary': isPrimary,
      };
      return realEstateProjectFromJson(
        await _remote.uploadMedia(projectId, unitId, body),
      );
    });
  }
}
