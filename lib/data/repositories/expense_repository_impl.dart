import '../../core/error/result.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/finance_remote_datasource.dart';
import 'remote_guard.dart';

/// Backend `ExpenseCategory` is `office | employee | supplier | other`; the
/// app's richer set folds `travel` / `meals` into `other`.
const Map<ExpenseCategory, String> _categoryToApi = {
  ExpenseCategory.travel: 'other',
  ExpenseCategory.meals: 'other',
  ExpenseCategory.office: 'office',
  ExpenseCategory.supplier: 'supplier',
  ExpenseCategory.other: 'other',
};

const Map<String, ExpenseCategory> _categoryFromApi = {
  'office': ExpenseCategory.office,
  'supplier': ExpenseCategory.supplier,
  'employee': ExpenseCategory.other,
  'other': ExpenseCategory.other,
};

const Map<String, ExpenseStatus> _statusFromApi = {
  'pending': ExpenseStatus.pending,
  'approved': ExpenseStatus.approved,
  'rejected': ExpenseStatus.rejected,
};

Expense _expenseFromJson(Map<String, dynamic> json) {
  final employee = json['employee'];
  return Expense(
    id: json['id'].toString(),
    category: _categoryFromApi[json['category']] ?? ExpenseCategory.other,
    amount: num.tryParse(json['amount']?.toString() ?? '') ?? 0,
    date:
        DateTime.tryParse(json['spent_on']?.toString() ?? '') ?? DateTime.now(),
    status: _statusFromApi[json['status']] ?? ExpenseStatus.pending,
    note: json['note'] as String? ?? json['title'] as String?,
    submittedBy: employee is Map ? employee['name'] as String? : null,
  );
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._remote);

  final FinanceRemoteDataSource _remote;

  @override
  Future<Result<List<Expense>>> mine() {
    return guardRequest(
      () async => (await _remote.expenses())
          .map(_expenseFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Expense>> submit({
    required ExpenseCategory category,
    required num amount,
    required DateTime date,
    String? note,
    bool hasReceipt = false,
  }) {
    return guardRequest(
      () async => _expenseFromJson(
        await _remote.createExpense({
          'title': (note == null || note.isEmpty) ? category.name : note,
          'category': _categoryToApi[category] ?? 'other',
          'amount': amount,
          'spent_on': date.toIso8601String().split('T').first,
          'method': 'cash',
        }),
      ),
    );
  }

  @override
  Future<Result<List<Expense>>> pendingApprovals() {
    return guardRequest(
      () async => (await _remote.pendingExpenses())
          .map(_expenseFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Expense>> decide({required String id, required bool approve}) {
    return guardRequest(
      () async =>
          _expenseFromJson(await _remote.decideExpense(id, approve: approve)),
    );
  }
}
