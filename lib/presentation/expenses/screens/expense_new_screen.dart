import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/expense.dart';
import '../controllers/expenses_controller.dart';
import '../expense_display.dart';

class ExpenseNewScreen extends StatefulWidget {
  const ExpenseNewScreen({super.key});

  @override
  State<ExpenseNewScreen> createState() => _ExpenseNewScreenState();
}

class _ExpenseNewScreenState extends State<ExpenseNewScreen> {
  final _controller = Get.find<ExpensesController>();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.travel;
  DateTime _date = DateTime.now();
  bool _receipt = false;
  bool _submitting = false;
  String? _amountError;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = num.tryParse(_amount.text.trim());
    setState(() => _amountError = (value == null || value <= 0) ? ' ' : null);
    if (value == null || value <= 0) return;

    setState(() => _submitting = true);
    final ok = await _controller.submit(
      category: _category,
      amount: value,
      date: _date,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      hasReceipt: _receipt,
    );
    setState(() => _submitting = false);
    if (ok && mounted) Get.back<bool>(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.expenseNew.tr)),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionLabel(Tr.expenseCategory.tr),
          SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final cat in ExpenseCategory.values)
                ChoiceChip(
                  avatar: Icon(cat.icon, size: 16),
                  label: Text(cat.labelKey.tr),
                  selected: _category == cat,
                  onSelected: (_) => setState(() => _category = cat),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: Tr.expenseAmount.tr,
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            prefixIcon: Icons.payments_outlined,
            errorText: _amountError,
          ),
          SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: Tr.expenseDate.tr,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(DateFormat.yMMMd().format(_date)),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: Tr.expenseNote.tr,
            controller: _note,
            maxLines: 2,
          ),
          SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Tr.expenseReceipt.tr),
            secondary: const Icon(Icons.attach_file),
            value: _receipt,
            onChanged: (v) => setState(() => _receipt = v),
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(
            label: Tr.expenseSubmit.tr,
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
