import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/leave_request.dart';
import '../controllers/leave_controller.dart';
import '../hr_display.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _controller = Get.find<LeaveController>();
  final _reason = TextEditingController();

  LeaveType _type = LeaveType.casual;
  DateTimeRange? _range;
  bool _submitting = false;
  String? _rangeError;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _submit() async {
    setState(() => _rangeError = _range == null ? Tr.leaveTo.tr : null);
    if (_range == null || _reason.text.trim().isEmpty) return;

    setState(() => _submitting = true);
    final ok = await _controller.submit(
      type: _type,
      from: _range!.start,
      to: _range!.end,
      reason: _reason.text.trim(),
    );
    setState(() => _submitting = false);
    if (ok && mounted) Get.back<bool>(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.MMMd();
    return Scaffold(
      appBar: AppBar(title: Text(Tr.leaveNew.tr)),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionLabel(Tr.leaveType.tr),
          SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final t in LeaveType.values)
                ChoiceChip(
                  label: Text(t.labelKey.tr),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: _pickRange,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '${Tr.leaveFrom.tr} – ${Tr.leaveTo.tr}',
                errorText: _rangeError,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(
                _range == null
                    ? '—'
                    : '${fmt.format(_range!.start)} – ${fmt.format(_range!.end)}',
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: Tr.leaveReason.tr,
            controller: _reason,
            maxLines: 3,
          ),
          SizedBox(height: AppSpacing.xl),
          AppButton(
            label: Tr.leaveSubmit.tr,
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
