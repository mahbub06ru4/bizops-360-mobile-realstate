import 'package:flutter/material.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/expense.dart';

extension ExpenseCategoryDisplay on ExpenseCategory {
  String get labelKey => switch (this) {
    ExpenseCategory.travel => Tr.expCatTravel,
    ExpenseCategory.meals => Tr.expCatMeals,
    ExpenseCategory.office => Tr.expCatOffice,
    ExpenseCategory.supplier => Tr.expCatSupplier,
    ExpenseCategory.other => Tr.expCatOther,
  };

  IconData get icon => switch (this) {
    ExpenseCategory.travel => Icons.local_taxi_outlined,
    ExpenseCategory.meals => Icons.restaurant_outlined,
    ExpenseCategory.office => Icons.print_outlined,
    ExpenseCategory.supplier => Icons.local_shipping_outlined,
    ExpenseCategory.other => Icons.category_outlined,
  };
}

extension ExpenseStatusDisplay on ExpenseStatus {
  String get labelKey => switch (this) {
    ExpenseStatus.pending => Tr.expStatusPending,
    ExpenseStatus.approved => Tr.expStatusApproved,
    ExpenseStatus.rejected => Tr.expStatusRejected,
    ExpenseStatus.reimbursed => Tr.expStatusReimbursed,
  };

  ChipTone get tone => switch (this) {
    ExpenseStatus.pending => ChipTone.signal,
    ExpenseStatus.approved => ChipTone.info,
    ExpenseStatus.rejected => ChipTone.critical,
    ExpenseStatus.reimbursed => ChipTone.brand,
  };
}
