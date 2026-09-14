import 'package:get/get.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../domain/entities/project_location.dart';
import '../../../../domain/entities/project_pricing.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/entities/unit.dart';
import '../../../../domain/repositories/real_estate_project_repository.dart';

/// The seller's "Post Project" flow — roadmap Phase 0: type → location → land
/// → building → amenities → media → contact. One controller owns every
/// step's form state; [finish] plays the steps back against the repository
/// as a sequence of mutations on a freshly created draft project.
enum PostProjectStep {
  type,
  location,
  land,
  building,
  amenities,
  media,
  contact,
}

const _fixedAmenities = [
  ('lift', 'Lift'),
  ('generator', 'Generator backup'),
  ('parking', 'Car parking'),
  ('security', '24/7 security'),
  ('mosque', 'Mosque / prayer space'),
  ('park', 'Park / open space'),
  ('gym', 'Gym'),
  ('community_hall', 'Community hall'),
];

class PostProjectController extends GetxController {
  PostProjectController(this._repo);

  final RealEstateProjectRepository _repo;

  final Rx<PostProjectStep> step = PostProjectStep.type.obs;

  // Step 1 — type
  final Rx<ProjectType> type = ProjectType.landShare.obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;

  // Step 2 — location
  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString area = ''.obs;
  final RxString sector = ''.obs;
  final RxString road = ''.obs;
  final RxString landmarks = ''.obs;

  // Step 3 — land
  final RxDouble landSizeSqft = 0.0.obs;
  final RxDouble landCost = 0.0.obs;

  // Step 4 — building / representative unit
  final RxString buildingName = 'Land parcel'.obs;
  final RxInt floors = 1.obs;
  final RxInt unitsPerFloor = 0.obs;
  final RxDouble constructionCost = 0.0.obs;
  final RxString unitNumber = ''.obs;
  final RxDouble unitSizeSqft = 0.0.obs;
  final RxDouble unitPrice = 0.0.obs;
  final RxInt unitBedrooms = 0.obs;
  final RxInt unitBathrooms = 0.obs;
  final RxInt unitParkingSpaces = 0.obs;
  final Rxn<UnitFacing> unitFacing = Rxn<UnitFacing>();

  // Step 5 — amenities
  final RxSet<String> selectedAmenities = <String>{}.obs;
  final RxString customAmenity = ''.obs;

  // Step 6 — media (already-picked local file paths / urls)
  final RxList<String> mediaPaths = <String>[].obs;

  // Step 7 — contact
  final RxString contactName = ''.obs;
  final RxString contactPhone = ''.obs;

  final RxBool submitting = false.obs;
  final RxnString error = RxnString();

  List<(String, String)> get amenityCatalog => _fixedAmenities;

  bool get isLandShare => type.value == ProjectType.landShare;

  bool canLeave(PostProjectStep s) => switch (s) {
    PostProjectStep.type => title.value.trim().isNotEmpty,
    PostProjectStep.location =>
      division.value.trim().isNotEmpty &&
          district.value.trim().isNotEmpty &&
          area.value.trim().isNotEmpty,
    PostProjectStep.land => landSizeSqft.value > 0,
    PostProjectStep.building =>
      unitNumber.value.trim().isNotEmpty && unitSizeSqft.value > 0,
    PostProjectStep.amenities => true,
    PostProjectStep.media => true,
    PostProjectStep.contact =>
      contactName.value.trim().isNotEmpty &&
          contactPhone.value.trim().isNotEmpty,
  };

  bool get canGoNext => canLeave(step.value);

  static const _order = PostProjectStep.values;

  void next() {
    final i = _order.indexOf(step.value);
    if (canGoNext && i < _order.length - 1) step.value = _order[i + 1];
  }

  void back() {
    final i = _order.indexOf(step.value);
    if (i > 0) step.value = _order[i - 1];
  }

  void toggleAmenity(String key) {
    if (!selectedAmenities.remove(key)) selectedAmenities.add(key);
  }

  void addCustomAmenity() {
    final name = customAmenity.value.trim();
    if (name.isEmpty) return;
    selectedAmenities.add(name);
    customAmenity.value = '';
  }

  void removeMedia(String path) => mediaPaths.remove(path);

  /// Plays the wizard's captured state back as a sequence of repository
  /// calls, returning the finished project on success or leaving [error] set.
  Future<RealEstateProject?> finish() async {
    if (!_order.every(canLeave)) {
      error.value = 'Complete every step before posting.';
      return null;
    }
    submitting.value = true;
    error.value = null;
    try {
      final created = await _repo.create(
        title: title.value.trim(),
        type: type.value,
        description: description.value.trim().isEmpty
            ? null
            : description.value.trim(),
      );
      final project = created.valueOrNull;
      if (project == null) {
        error.value = _message(created.failureOrNull);
        return null;
      }
      var current = project;

      final located = await _repo.addLocation(
        current.id,
        location: ProjectLocation(
          division: division.value.trim(),
          district: district.value.trim(),
          area: area.value.trim(),
          sector: sector.value.trim().isEmpty ? null : sector.value.trim(),
          road: road.value.trim().isEmpty ? null : road.value.trim(),
          landmarks: landmarks.value
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        ),
      );
      current = _unwrapOr(located, current);

      final withBuilding = await _repo.addBuilding(
        current.id,
        name: buildingName.value.trim().isEmpty
            ? 'Land parcel'
            : buildingName.value.trim(),
        floors: floors.value < 1 ? 1 : floors.value,
        unitsPerFloor: unitsPerFloor.value > 0 ? unitsPerFloor.value : null,
      );
      current = _unwrapOr(withBuilding, current);
      final buildingId = current.buildings.isEmpty
          ? null
          : current.buildings.last.id;

      if (buildingId != null) {
        final withUnit = await _repo.addUnit(
          current.id,
          buildingId,
          unitNumber: unitNumber.value.trim(),
          sizeSqft: unitSizeSqft.value,
          bedrooms: unitBedrooms.value > 0 ? unitBedrooms.value : null,
          bathrooms: unitBathrooms.value > 0 ? unitBathrooms.value : null,
          facing: unitFacing.value,
          parkingSpaces: unitParkingSpaces.value > 0
              ? unitParkingSpaces.value
              : null,
          priceAmount: unitPrice.value > 0 ? unitPrice.value : null,
          priceLabel: isLandShare ? 'Per katha' : 'Total price',
        );
        current = _unwrapOr(withUnit, current);
      }

      for (final key in selectedAmenities) {
        final label = _fixedAmenities
            .where((a) => a.$1 == key)
            .map((a) => a.$2)
            .firstOrNull;
        final withAmenity = await _repo.addAmenity(
          current.id,
          name: label ?? key,
          icon: label == null ? null : key,
        );
        current = _unwrapOr(withAmenity, current);
      }

      final withPricing = await _repo.setPricing(
        current.id,
        pricing: ProjectPricing(
          landCost: landCost.value,
          constructionCost: constructionCost.value,
        ),
      );
      current = _unwrapOr(withPricing, current);

      final unitId =
          current.buildings.isEmpty || current.buildings.last.units.isEmpty
          ? null
          : current.buildings.last.units.last.id;
      if (unitId != null) {
        for (final path in mediaPaths) {
          final withMedia = await _repo.uploadMedia(
            current.id,
            unitId,
            url: path,
            isPrimary: path == mediaPaths.first,
          );
          current = _unwrapOr(withMedia, current);
        }
      }

      final withContact = await _repo.update(
        current.id,
        contactName: contactName.value.trim(),
        contactPhone: contactPhone.value.trim(),
      );
      current = _unwrapOr(withContact, current);

      return current;
    } finally {
      submitting.value = false;
    }
  }

  RealEstateProject _unwrapOr(
    Result<RealEstateProject> result,
    RealEstateProject fallback,
  ) => result.valueOrNull ?? fallback;

  String _message(Failure? f) => f?.message ?? 'Something went wrong.';
}
