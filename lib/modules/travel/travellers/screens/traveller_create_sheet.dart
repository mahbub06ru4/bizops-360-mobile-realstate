import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/travellers_controller.dart';

/// Quick-create sheet for a traveller. Returns true when one was created.
Future<bool> showTravellerCreateSheet(TravellersController controller) async {
  final result = await AppBottomSheet.show<bool>(
    _TravellerCreateForm(controller),
  );
  return result ?? false;
}

class _TravellerCreateForm extends StatefulWidget {
  const _TravellerCreateForm(this.controller);

  final TravellersController controller;

  @override
  State<_TravellerCreateForm> createState() => _TravellerCreateFormState();
}

class _TravellerCreateFormState extends State<_TravellerCreateForm> {
  final _name = TextEditingController();
  final _nationality = TextEditingController();
  final _phone = TextEditingController();
  final _passport = TextEditingController();

  DateTime? _expiry;
  bool _submitting = false;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _nationality.dispose();
    _phone.dispose();
    _passport.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = Tr.travFullName.tr);
      return;
    }
    setState(() {
      _submitting = true;
      _nameError = null;
    });
    final ok = await widget.controller.create(
      name: name,
      nationality: _nationality.text.trim(),
      phone: _phone.text.trim(),
      passportNumber: _passport.text.trim(),
      passportExpiry: _expiry,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Get.back<bool>(result: true);
    } else {
      AppSnackbar.error(
        widget.controller.createError.value ?? Tr.somethingWrong.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(Tr.travNew.tr, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.travFullName.tr,
          controller: _name,
          errorText: _nameError,
        ),
        SizedBox(height: AppSpacing.sm),
        AppTextField(label: Tr.travNationality.tr, controller: _nationality),
        SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: Tr.travPhone.tr,
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: AppSpacing.sm),
        AppTextField(label: Tr.travPassportNo.tr, controller: _passport),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  _expiry ?? DateTime(now.year + 5, now.month, now.day),
              firstDate: DateTime(now.year - 20),
              lastDate: DateTime(now.year + 20),
            );
            if (picked != null) setState(() => _expiry = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: Tr.travExpiry.tr,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            child: Text(
              _expiry == null ? '—' : DateFormat.yMMMd().format(_expiry!),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppButton(label: Tr.save.tr, loading: _submitting, onPressed: _submit),
      ],
    );
  }
}
