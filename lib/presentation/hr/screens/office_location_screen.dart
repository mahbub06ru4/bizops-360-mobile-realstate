import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/office_location.dart';
import '../controllers/office_location_controller.dart';

/// Lets a manager / admin / HR set the office geofence + working hours that
/// drive attendance tagging. Gated on `Perm.attendanceManage`.
class OfficeLocationScreen extends GetView<OfficeLocationController> {
  const OfficeLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.officeLocTitle.tr)),
      body: Obx(
        () => AsyncView<OfficeLocation>(
          value: controller.state.value,
          onRetry: controller.load,
          data: (office) => _Form(office: office),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.office});

  final OfficeLocation office;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final _label = TextEditingController(text: widget.office.label);
  late final _lat = TextEditingController(
    text: widget.office.latitude.toString(),
  );
  late final _lng = TextEditingController(
    text: widget.office.longitude.toString(),
  );
  late final _radius = TextEditingController(
    text: widget.office.radiusMeters.toStringAsFixed(0),
  );
  late final _start = TextEditingController(text: widget.office.startTime);
  late final _end = TextEditingController(text: widget.office.endTime);
  OfficeLocation? _lastSynced;

  @override
  void didUpdateWidget(covariant _Form oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastSynced != widget.office &&
        widget.office.latitude != double.tryParse(_lat.text)) {
      _lat.text = widget.office.latitude.toString();
      _lng.text = widget.office.longitude.toString();
      _lastSynced = widget.office;
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _lat.dispose();
    _lng.dispose();
    _radius.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OfficeLocationController>();
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        AppTextField(label: Tr.officeLocLabel.tr, controller: _label),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: Tr.officeLocLat.tr,
                controller: _lat,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: Tr.officeLocLng.tr,
                controller: _lng,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(
          () => AppButton(
            label: Tr.officeLocUseCurrent.tr,
            icon: Icons.my_location,
            variant: AppButtonVariant.secondary,
            loading: controller.locating.value,
            onPressed: controller.useCurrentLocation,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.officeLocRadius.tr,
          controller: _radius,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: Tr.officeLocStart.tr,
                controller: _start,
                hint: '10:00',
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: Tr.officeLocEnd.tr,
                controller: _end,
                hint: '18:00',
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        Obx(
          () => AppButton(
            label: Tr.save.tr,
            loading: controller.saving.value,
            onPressed: () async {
              final lat = double.tryParse(_lat.text);
              final lng = double.tryParse(_lng.text);
              final radius = double.tryParse(_radius.text);
              if (lat == null || lng == null || radius == null) {
                AppSnackbar.error(Tr.officeLocInvalid.tr);
                return;
              }
              final ok = await controller.save(
                label: _label.text.trim(),
                latitude: lat,
                longitude: lng,
                radiusMeters: radius,
                startTime: _start.text.trim(),
                endTime: _end.text.trim(),
              );
              if (ok) {
                AppSnackbar.show(
                  Tr.officeLocSaved.tr,
                  tone: FeedbackTone.success,
                );
              } else {
                AppSnackbar.error(Tr.somethingWrong.tr);
              }
            },
          ),
        ),
      ],
    );
  }
}
