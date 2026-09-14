import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/invoice_detail_controller.dart';

/// Returns true when a payment was recorded.
Future<bool> showRecordPaymentSheet(InvoiceDetailController controller) async {
  final r = await AppBottomSheet.show<bool>(_RecordPaymentForm(controller));
  return r ?? false;
}

class _RecordPaymentForm extends StatefulWidget {
  const _RecordPaymentForm(this.controller);

  final InvoiceDetailController controller;

  @override
  State<_RecordPaymentForm> createState() => _RecordPaymentFormState();
}

class _RecordPaymentFormState extends State<_RecordPaymentForm> {
  final _amount = TextEditingController();
  final _method = TextEditingController();
  final _note = TextEditingController();
  bool _submitting = false;
  String? _amountError;

  @override
  void dispose() {
    _amount.dispose();
    _method.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = num.tryParse(_amount.text.trim());
    setState(() => _amountError = (value == null || value <= 0) ? ' ' : null);
    if (value == null || value <= 0 || _method.text.trim().isEmpty) return;

    setState(() => _submitting = true);
    final ok = await widget.controller.recordPayment(
      amount: value,
      method: _method.text.trim(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
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
        Text(
          Tr.invRecordPayment.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: Tr.invPaymentAmount.tr,
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.payments_outlined,
          errorText: _amountError,
        ),
        SizedBox(height: AppSpacing.sm),
        AppTextField(label: Tr.invPaymentMethod.tr, controller: _method),
        SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: Tr.invPaymentNote.tr,
          controller: _note,
          maxLines: 2,
        ),
        SizedBox(height: AppSpacing.lg),
        AppButton(label: Tr.save.tr, loading: _submitting, onPressed: _submit),
      ],
    );
  }
}
