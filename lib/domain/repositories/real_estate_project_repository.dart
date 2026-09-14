import '../../core/error/result.dart';
import '../entities/payment_plan.dart';
import '../entities/project_location.dart';
import '../entities/project_pricing.dart';
import '../entities/real_estate_project.dart';
import '../entities/unit.dart';

/// The real-estate vertical's single aggregate repository (`industry:
/// real_estate` gated). Every mutation returns the whole updated
/// [RealEstateProject] so the seller's Post Project wizard and the shared
/// detail screen can just replace their state — no separate sub-resource
/// controllers for Phase 0.
abstract interface class RealEstateProjectRepository {
  /// Every project the current seller/tenant owns, newest first.
  Future<Result<List<RealEstateProject>>> list();

  Future<Result<RealEstateProject>> getById(String id);

  Future<Result<RealEstateProject>> create({
    required String title,
    required ProjectType type,
    String? description,
  });

  Future<Result<RealEstateProject>> update(
    String id, {
    String? title,
    String? description,
    String? contactName,
    String? contactPhone,
  });

  /// Moves a draft to `submitted` for admin verification review. Fails with a
  /// [ValidationFailure]-shaped [Result] when the project isn't complete
  /// enough to submit (mirrors [RealEstateProject.canSubmit]).
  Future<Result<RealEstateProject>> submitForVerification(String id);

  Future<Result<RealEstateProject>> addBuilding(
    String projectId, {
    required String name,
    required int floors,
    int? unitsPerFloor,
  });

  /// [priceAmount]/[priceLabel] seed the unit's first [UnitPrice] line (e.g.
  /// "Total price", "Per katha") — Phase 0 has no separate unit-pricing
  /// endpoint, so the initial price rides along with unit creation.
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
  });

  Future<Result<RealEstateProject>> addLocation(
    String projectId, {
    required ProjectLocation location,
  });

  Future<Result<RealEstateProject>> addAmenity(
    String projectId, {
    required String name,
    String? icon,
  });

  Future<Result<RealEstateProject>> setPricing(
    String projectId, {
    required ProjectPricing pricing,
  });

  Future<Result<RealEstateProject>> addPaymentPlan(
    String projectId, {
    required PaymentPlan plan,
  });

  /// Attaches a photo to [unitId] within [projectId]. Phase 0 takes an
  /// already-hosted `url` (the picked file is uploaded by the datasource as
  /// multipart — see `RealEstateRemoteDataSource.uploadMedia`); the fake
  /// repository just stores the local file path.
  Future<Result<RealEstateProject>> uploadMedia(
    String projectId,
    String unitId, {
    required String url,
    String? caption,
    bool isPrimary = false,
  });
}
