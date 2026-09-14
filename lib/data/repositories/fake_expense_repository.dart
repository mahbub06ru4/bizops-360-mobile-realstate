import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

/// In-memory expenses for UI-first development (`Env.useFakeData`).
class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository() : _items = _seed(), _pending = _seedPending();

  List<Expense> _items;
  List<Expense> _pending;
  var _nextId = 200;

  static List<Expense> _seedPending() => [
    Expense(
      id: 'ep1',
      category: ExpenseCategory.travel,
      amount: 2400,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: ExpenseStatus.pending,
      note: 'Taxi for airport transfers, Bali group.',
      hasReceipt: true,
      submittedBy: 'Rahim Uddin',
    ),
    Expense(
      id: 'ep2',
      category: ExpenseCategory.supplier,
      amount: 9000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: ExpenseStatus.pending,
      note: 'Visa agent service charge.',
      submittedBy: 'Sadia Islam',
    ),
  ];

  static DateTime _ago(int d) => DateTime.now().subtract(Duration(days: d));

  static List<Expense> _seed() => [
    Expense(
      id: 'e1',
      category: ExpenseCategory.travel,
      amount: 1200,
      date: _ago(1),
      status: ExpenseStatus.pending,
      note: 'CNG to airport for client pickup.',
      hasReceipt: true,
    ),
    Expense(
      id: 'e2',
      category: ExpenseCategory.meals,
      amount: 3400,
      date: _ago(3),
      status: ExpenseStatus.approved,
      note: 'Lunch with the Bali group.',
      hasReceipt: true,
    ),
    Expense(
      id: 'e3',
      category: ExpenseCategory.office,
      amount: 850,
      date: _ago(6),
      status: ExpenseStatus.reimbursed,
      note: 'Printer paper and toner.',
    ),
    Expense(
      id: 'e4',
      category: ExpenseCategory.supplier,
      amount: 15000,
      date: _ago(10),
      status: ExpenseStatus.rejected,
      note: 'Advance to visa agent — use company account instead.',
    ),
  ];

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  @override
  Future<Result<List<Expense>>> mine() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<Expense>> submit({
    required ExpenseCategory category,
    required num amount,
    required DateTime date,
    String? note,
    bool hasReceipt = false,
  }) {
    final expense = Expense(
      id: '${_nextId++}',
      category: category,
      amount: amount,
      date: date,
      status: ExpenseStatus.pending,
      note: note,
      hasReceipt: hasReceipt,
    );
    _items = [expense, ..._items];
    return _delayed(Result.ok(expense));
  }

  @override
  Future<Result<List<Expense>>> pendingApprovals() =>
      _delayed(Result.ok(List.unmodifiable(_pending)));

  @override
  Future<Result<Expense>> decide({required String id, required bool approve}) {
    Expense? decided;
    _pending = [
      for (final e in _pending)
        if (e.id == id)
          decided = e.copyWith(
            status: approve ? ExpenseStatus.approved : ExpenseStatus.rejected,
          )
        else
          e,
    ]..removeWhere((e) => e.id == id);
    final result = decided;
    return _delayed(
      result == null ? const Result.err(NotFoundFailure()) : Result.ok(result),
    );
  }
}
