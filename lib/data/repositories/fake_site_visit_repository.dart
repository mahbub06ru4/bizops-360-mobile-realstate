import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/site_visit.dart';
import '../../domain/repositories/site_visit_repository.dart';

/// In-memory site visits for UI-first development.
class FakeSiteVisitRepository implements SiteVisitRepository {
  FakeSiteVisitRepository() : _items = _seed();

  List<SiteVisit> _items;
  var _nextId = 600;

  static DateTime _ago(int days) =>
      DateTime.now().subtract(Duration(days: days));
  static DateTime _in(int days) => DateTime.now().add(Duration(days: days));

  static List<SiteVisit> _seed() => [
    SiteVisit(
      id: 'sv1',
      leadId: 'c2',
      leadName: 'Nusrat Jahan',
      unitId: 'u3',
      unitName: 'A-3B',
      projectId: 'rp2',
      projectTitle: 'Khulshi Heights',
      scheduledAt: _in(3),
      status: SiteVisitStatus.scheduled,
      createdAt: _ago(4),
    ),
    SiteVisit(
      id: 'sv2',
      leadId: 'c1',
      leadName: 'Rahim Uddin',
      unitId: 'u1',
      unitName: 'Share #1',
      projectId: 'rp1',
      projectTitle: 'Diabari Green Residency (Land-share)',
      scheduledAt: _ago(5),
      status: SiteVisitStatus.completed,
      feedback: 'Liked the road-facing corner.',
      createdAt: _ago(10),
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  SiteVisit? _find(String id) => _items.where((v) => v.id == id).firstOrNull;

  Result<SiteVisit> _replace(SiteVisit v) {
    _items = [
      for (final x in _items)
        if (x.id == v.id) v else x,
    ];
    return Result.ok(v);
  }

  @override
  Future<Result<List<SiteVisit>>> list({String? status}) => _delayed(
    Result.ok(
      List.unmodifiable(
        <SiteVisit>[
          for (final v in _items)
            if (status == null || v.status.name == status) v,
        ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
      ),
    ),
  );

  @override
  Future<Result<SiteVisit>> schedule({
    required String leadId,
    required String leadName,
    required DateTime scheduledAt,
    String? unitId,
    String? unitName,
    String? projectId,
    String? projectTitle,
    String? conductedByEmployeeId,
  }) {
    final visit = SiteVisit(
      id: 'sv${_nextId++}',
      leadId: leadId,
      leadName: leadName,
      unitId: unitId,
      unitName: unitName,
      projectId: projectId,
      projectTitle: projectTitle,
      scheduledAt: scheduledAt,
      status: SiteVisitStatus.scheduled,
      conductedByEmployeeId: conductedByEmployeeId,
      createdAt: DateTime.now(),
    );
    _items = [visit, ..._items];
    return _delayed(Result.ok(visit));
  }

  @override
  Future<Result<SiteVisit>> complete(String id, {String? feedback}) {
    final v = _find(id);
    if (v == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(
      _replace(
        v.copyWith(status: SiteVisitStatus.completed, feedback: feedback),
      ),
    );
  }

  @override
  Future<Result<SiteVisit>> cancel(String id) {
    final v = _find(id);
    if (v == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(_replace(v.copyWith(status: SiteVisitStatus.cancelled)));
  }
}
