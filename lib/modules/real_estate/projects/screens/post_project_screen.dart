import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/entities/unit.dart';
import '../controllers/post_project_controller.dart';
import '../project_display.dart';

/// The seller's "Post Project" wizard (roadmap Phase 0 flow): type → location
/// → land → building → amenities → media → contact. One screen swaps its body
/// per [PostProjectController.step]; Next/Back/Finish drive the same
/// controller.
class PostProjectScreen extends GetView<PostProjectController> {
  const PostProjectScreen({super.key});

  String _stepTitle(PostProjectStep s) => switch (s) {
    PostProjectStep.type => Tr.ppStepType.tr,
    PostProjectStep.location => Tr.ppStepLocation.tr,
    PostProjectStep.land => Tr.ppStepLand.tr,
    PostProjectStep.building => Tr.ppStepBuilding.tr,
    PostProjectStep.amenities => Tr.ppStepAmenities.tr,
    PostProjectStep.media => Tr.ppStepMedia.tr,
    PostProjectStep.contact => Tr.ppStepContact.tr,
  };

  Widget _stepBody(PostProjectStep s) => switch (s) {
    PostProjectStep.type => _TypeStep(controller: controller),
    PostProjectStep.location => _LocationStep(controller: controller),
    PostProjectStep.land => _LandStep(controller: controller),
    PostProjectStep.building => _BuildingStep(controller: controller),
    PostProjectStep.amenities => _AmenitiesStep(controller: controller),
    PostProjectStep.media => _MediaStep(controller: controller),
    PostProjectStep.contact => _ContactStep(controller: controller),
  };

  @override
  Widget build(BuildContext context) {
    const steps = PostProjectStep.values;

    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(_stepTitle(controller.step.value)))),
      body: Column(
        children: [
          Obx(() {
            final i = steps.indexOf(controller.step.value);
            return LinearProgressIndicator(
              value: (i + 1) / steps.length,
              minHeight: 3,
            );
          }),
          Expanded(
            child: Obx(
              () => SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: _stepBody(controller.step.value),
              ),
            ),
          ),
          SafeArea(
            minimum: EdgeInsets.all(AppSpacing.lg),
            child: Obx(() {
              final isFirst = controller.step.value == steps.first;
              final isLast = controller.step.value == steps.last;
              return Row(
                children: [
                  if (!isFirst)
                    Expanded(
                      child: AppButton(
                        label: Tr.ppBack.tr,
                        variant: AppButtonVariant.secondary,
                        onPressed: controller.back,
                      ),
                    ),
                  if (!isFirst) SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: isLast ? Tr.ppFinish.tr : Tr.ppNext.tr,
                      loading: controller.submitting.value,
                      onPressed: !controller.canGoNext
                          ? null
                          : isLast
                          ? () async {
                              final project = await controller.finish();
                              if (project == null) {
                                AppSnackbar.error(
                                  controller.error.value ?? Tr.ppIncomplete.tr,
                                );
                                return;
                              }
                              AppSnackbar.show(
                                Tr.ppCreated.tr,
                                tone: FeedbackTone.success,
                              );
                              await Get.offNamed<void>(
                                Routes.projectDetail,
                                arguments: project,
                              );
                            }
                          : controller.next,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TypeStep extends StatelessWidget {
  const _TypeStep({required this.controller});

  final PostProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => AppDropdown<ProjectType>(
            label: Tr.ppStepType.tr,
            value: controller.type.value,
            items: [
              for (final t in ProjectType.values)
                AppDropdownItem(t, t.labelKey.tr, icon: t.icon),
            ],
            onChanged: (t) =>
                controller.type.value = t ?? controller.type.value,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppProjectTitle.tr,
          onChanged: (v) => controller.title.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppProjectDescription.tr,
          maxLines: 3,
          onChanged: (v) => controller.description.value = v,
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.controller});

  final PostProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: Tr.ppDivision.tr,
          onChanged: (v) => controller.division.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppDistrict.tr,
          onChanged: (v) => controller.district.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppArea.tr,
          onChanged: (v) => controller.area.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppSector.tr,
          onChanged: (v) => controller.sector.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppRoad.tr,
          onChanged: (v) => controller.road.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppLandmarks.tr,
          onChanged: (v) => controller.landmarks.value = v,
        ),
      ],
    );
  }
}

class _LandStep extends StatelessWidget {
  const _LandStep({required this.controller});

  final PostProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: Tr.ppLandSize.tr,
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              controller.landSizeSqft.value = double.tryParse(v) ?? 0,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppLandCost.tr,
          keyboardType: TextInputType.number,
          onChanged: (v) => controller.landCost.value = double.tryParse(v) ?? 0,
        ),
      ],
    );
  }
}

class _BuildingStep extends StatelessWidget {
  const _BuildingStep({required this.controller});

  final PostProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: Tr.ppBuildingName.tr,
            onChanged: (v) => controller.buildingName.value = v,
          ),
          if (!controller.isLandShare) ...[
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.ppFloors.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) => controller.floors.value = int.tryParse(v) ?? 1,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.ppUnitsPerFloor.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.unitsPerFloor.value = int.tryParse(v) ?? 0,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.ppConstructionCost.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.constructionCost.value = double.tryParse(v) ?? 0,
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: Tr.ppUnitNumber.tr,
            onChanged: (v) => controller.unitNumber.value = v,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: Tr.ppUnitSize.tr,
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                controller.unitSizeSqft.value = double.tryParse(v) ?? 0,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: Tr.ppUnitPrice.tr,
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                controller.unitPrice.value = double.tryParse(v) ?? 0,
          ),
          if (!controller.isLandShare) ...[
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.ppUnitBedrooms.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.unitBedrooms.value = int.tryParse(v) ?? 0,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.ppUnitBathrooms.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.unitBathrooms.value = int.tryParse(v) ?? 0,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.ppUnitParkingSpaces.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.unitParkingSpaces.value = int.tryParse(v) ?? 0,
            ),
          ],
          SizedBox(height: AppSpacing.md),
          AppDropdown<UnitFacing>(
            label: Tr.ppUnitFacing.tr,
            value: controller.unitFacing.value,
            items: [
              for (final f in UnitFacing.values)
                AppDropdownItem(f, f.labelKey.tr),
            ],
            onChanged: (f) => controller.unitFacing.value = f,
          ),
        ],
      ),
    );
  }
}

class _AmenitiesStep extends StatelessWidget {
  const _AmenitiesStep({required this.controller});

  final PostProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (key, label) in controller.amenityCatalog)
                FilterChip(
                  avatar: Icon(amenityIcon(key), size: 16),
                  label: Text(label),
                  selected: controller.selectedAmenities.contains(key),
                  onSelected: (_) => controller.toggleAmenity(key),
                ),
              for (final custom in controller.selectedAmenities.where(
                (k) => !controller.amenityCatalog.any((a) => a.$1 == k),
              ))
                InputChip(
                  label: Text(custom),
                  onDeleted: () => controller.toggleAmenity(custom),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: Tr.ppCustomAmenity.tr,
                  onChanged: (v) => controller.customAmenity.value = v,
                  onSubmitted: (_) => controller.addCustomAmenity(),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: controller.addCustomAmenity,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaStep extends StatelessWidget {
  const _MediaStep({required this.controller});

  final PostProjectController controller;

  Future<void> _pick() async {
    final picked = await ImagePicker().pickMultiImage();
    controller.mediaPaths.addAll(picked.map((x) => x.path));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: Tr.ppAddPhotos.tr,
            icon: Icons.add_photo_alternate_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: _pick,
          ),
          if (controller.mediaPaths.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final path in controller.mediaPaths)
                  _MediaThumb(
                    path: path,
                    onRemove: () => controller.removeMedia(path),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.line),
          ),
          child: const Icon(Icons.image_outlined),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: c.ink,
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactStep extends StatelessWidget {
  const _ContactStep({required this.controller});

  final PostProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: Tr.ppContactName.tr,
          onChanged: (v) => controller.contactName.value = v,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.ppContactPhone.tr,
          keyboardType: TextInputType.phone,
          onChanged: (v) => controller.contactPhone.value = v,
        ),
      ],
    );
  }
}
