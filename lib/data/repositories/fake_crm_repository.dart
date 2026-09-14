import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/follow_up.dart';
import '../../domain/repositories/crm_repository.dart';

/// In-memory CRM data for UI-first development (`Env.useFakeData`).
class FakeCrmRepository implements CrmRepository {
  FakeCrmRepository()
    : _customers = _seedCustomers(),
      _followUps = _seedFollowUps();

  List<Customer> _customers;
  List<FollowUp> _followUps;

  static DateTime _ago(int days) =>
      DateTime.now().subtract(Duration(days: days));
  static DateTime _in(int days) => DateTime.now().add(Duration(days: days));

  static List<Customer> _seedCustomers() => [
    Customer(
      id: 'c1',
      name: 'Rahim Uddin',
      stage: PipelineStage.followUp,
      phone: '+8801711000001',
      source: 'Facebook',
      value: 180000,
      note: 'Schengen tour for 4, flexible on dates.',
      lastActivityAt: _ago(1),
    ),
    Customer(
      id: 'c2',
      name: 'Nusrat Jahan',
      stage: PipelineStage.negotiation,
      phone: '+8801711000002',
      source: 'Referral',
      value: 320000,
      note: 'Dubai package, wants a better hotel.',
      lastActivityAt: _ago(2),
    ),
    Customer(
      id: 'c3',
      name: 'Karim Traders',
      stage: PipelineStage.newLead,
      phone: '+8801711000003',
      source: 'Walk-in',
      value: 90000,
      lastActivityAt: _ago(0),
    ),
    Customer(
      id: 'c4',
      name: 'Sadia Islam',
      stage: PipelineStage.interested,
      phone: '+8801711000004',
      source: 'Website',
      value: 140000,
      lastActivityAt: _ago(4),
    ),
    Customer(
      id: 'c5',
      name: 'Hasan & family',
      stage: PipelineStage.converted,
      phone: '+8801711000005',
      source: 'Referral',
      value: 260000,
      lastActivityAt: _ago(9),
    ),
  ];

  static List<FollowUp> _seedFollowUps() => [
    FollowUp(
      id: 'f1',
      customerId: 'c1',
      customerName: 'Rahim Uddin',
      dueAt: DateTime.now(),
      channel: FollowUpChannel.call,
      note: 'Share the revised Schengen quote.',
    ),
    FollowUp(
      id: 'f2',
      customerId: 'c2',
      customerName: 'Nusrat Jahan',
      dueAt: _ago(1),
      channel: FollowUpChannel.whatsapp,
      note: 'Send the upgraded hotel options.',
    ),
    FollowUp(
      id: 'f3',
      customerId: 'c4',
      customerName: 'Sadia Islam',
      dueAt: _in(2),
      channel: FollowUpChannel.email,
      note: 'Follow up on the website enquiry.',
    ),
  ];

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => value);

  @override
  Future<Result<List<Customer>>> customers() =>
      _delayed(Result.ok(List.unmodifiable(_customers)));

  @override
  Future<Result<Customer>> customer(String id) {
    final match = _customers.where((c) => c.id == id).firstOrNull;
    return _delayed(
      match == null ? const Result.err(NotFoundFailure()) : Result.ok(match),
    );
  }

  @override
  Future<Result<List<CustomerActivity>>> history(String id) => _delayed(
    Result.ok([
      CustomerActivity(
        id: 'a1',
        at: _ago(1),
        summary: 'Call — discussed dates',
        detail: 'Prefers mid-November, 8 nights.',
      ),
      CustomerActivity(id: 'a2', at: _ago(3), summary: 'Quote sent'),
      CustomerActivity(
        id: 'a3',
        at: _ago(6),
        summary: 'Lead created from Facebook',
      ),
    ]),
  );

  @override
  Future<Result<Customer>> moveStage(String id, PipelineStage stage) {
    Customer? updated;
    _customers = [
      for (final c in _customers)
        if (c.id == id) updated = c.copyWith(stage: stage) else c,
    ];
    final result = updated;
    return _delayed(
      result == null ? const Result.err(NotFoundFailure()) : Result.ok(result),
    );
  }

  @override
  Future<Result<List<FollowUp>>> followUps() =>
      _delayed(Result.ok(List.unmodifiable(_followUps)));

  @override
  Future<Result<FollowUp>> completeFollowUp(
    String id,
    FollowUpOutcome outcome,
  ) {
    FollowUp? updated;
    _followUps = [
      for (final f in _followUps)
        if (f.id == id) updated = f.complete(outcome) else f,
    ];
    final result = updated;
    return _delayed(
      result == null ? const Result.err(NotFoundFailure()) : Result.ok(result),
    );
  }
}
