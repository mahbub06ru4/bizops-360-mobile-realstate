import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/booking.dart';
import '../booking_display.dart';
import '../controllers/bookings_controller.dart';

/// Minimal quick-create sheet. Returns true when a booking was created.
Future<bool> showBookingCreateSheet(BookingsController controller) async {
  final result = await AppBottomSheet.show<bool>(
    _BookingCreateForm(controller),
  );
  return result ?? false;
}

class _BookingCreateForm extends StatefulWidget {
  const _BookingCreateForm(this.controller);

  final BookingsController controller;

  @override
  State<_BookingCreateForm> createState() => _BookingCreateFormState();
}

class _BookingCreateFormState extends State<_BookingCreateForm> {
  final _traveller = TextEditingController();
  final _reference = TextEditingController();
  final _amount = TextEditingController();

  BookingKind _kind = BookingKind.flight;
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  bool _submitting = false;

  @override
  void dispose() {
    _traveller.dispose();
    _reference.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = num.tryParse(_amount.text.trim()) ?? 0;
    if (_traveller.text.trim().isEmpty || _reference.text.trim().isEmpty) {
      return;
    }
    setState(() => _submitting = true);
    final ok = await widget.controller.quickCreate(
      travellerName: _traveller.text.trim(),
      kind: _kind,
      reference: _reference.text.trim(),
      travelDate: _date,
      amount: amount,
    );
    setState(() => _submitting = false);
    if (ok && mounted) Get.back<bool>(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(Tr.bkNew.tr, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final k in BookingKind.values)
              ChoiceChip(
                avatar: Icon(k.icon, size: 16),
                label: Text(k.labelKey.tr),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(label: Tr.bkTraveller.tr, controller: _traveller),
        SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: Tr.bkRef.tr,
          controller: _reference,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: Tr.bkAmount.tr,
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _date = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: Tr.bkDate.tr,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            child: Text(DateFormat.yMMMd().format(_date)),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppButton(label: Tr.save.tr, loading: _submitting, onPressed: _submit),
      ],
    );
  }
}
