import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/visa_application.dart';
import '../../domain/repositories/visa_repository.dart';

/// In-memory visa cases for UI-first development (`Env.useFakeData`).
class FakeVisaRepository implements VisaRepository {
  FakeVisaRepository() : _items = _seed();

  List<VisaApplication> _items;

  static DateTime _ago(int d) => DateTime.now().subtract(Duration(days: d));

  static const _schengenDocs = [
    'Passport (6+ months)',
    'Photographs',
    'Bank statement',
    'Travel insurance',
    'Hotel booking',
    'Flight itinerary',
    'Cover letter',
  ];

  static List<VisaApplication> _seed() => [
    VisaApplication(
      id: 'v1',
      travellerName: 'Karim Rahman',
      country: 'France',
      category: 'Schengen · Tourist',
      stage: VisaStage.docsCollected,
      docs: [for (final d in _schengenDocs) VisaDoc(name: d, collected: true)],
    ),
    VisaApplication(
      id: 'v2',
      travellerName: 'Ayesha Karim',
      country: 'France',
      category: 'Schengen · Tourist',
      stage: VisaStage.docsRequired,
      docs: [
        for (var i = 0; i < _schengenDocs.length; i++)
          VisaDoc(name: _schengenDocs[i], collected: i < 3),
      ],
    ),
    VisaApplication(
      id: 'v3',
      travellerName: 'Tanvir Hasan',
      country: 'UAE',
      category: 'Visit · 30 days',
      stage: VisaStage.processing,
      docs: const [
        VisaDoc(name: 'Passport', collected: true),
        VisaDoc(name: 'Photograph', collected: true),
        VisaDoc(name: 'Confirmed ticket', collected: true),
      ],
      submittedAt: _ago(4),
    ),
    VisaApplication(
      id: 'v4',
      travellerName: 'Farhana Akter',
      country: 'Canada',
      category: 'Visitor',
      stage: VisaStage.submitted,
      docs: const [
        VisaDoc(name: 'Passport', collected: true),
        VisaDoc(name: 'IMM 5257 form', collected: true),
        VisaDoc(name: 'Proof of funds', collected: true),
        VisaDoc(name: 'Invitation letter', collected: true),
      ],
      submittedAt: _ago(1),
    ),
    VisaApplication(
      id: 'v5',
      travellerName: 'Mizanur Rahman',
      country: 'Thailand',
      category: 'Visa on arrival',
      stage: VisaStage.approved,
      docs: const [VisaDoc(name: 'Passport', collected: true)],
      submittedAt: _ago(9),
      decisionAt: _ago(7),
    ),
  ];

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => value);

  VisaApplication? _find(String id) =>
      _items.where((a) => a.id == id).firstOrNull;

  Result<VisaApplication> _replace(String id, VisaApplication updated) {
    _items = [
      for (final a in _items)
        if (a.id == id) updated else a,
    ];
    return Result.ok(updated);
  }

  @override
  Future<Result<List<VisaApplication>>> applications() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<VisaApplication>> byId(String id) {
    final a = _find(id);
    return _delayed(
      a == null ? const Result.err(NotFoundFailure()) : Result.ok(a),
    );
  }

  @override
  Future<Result<VisaApplication>> toggleDoc(String id, String docName) {
    final a = _find(id);
    if (a == null) return _delayed(const Result.err(NotFoundFailure()));
    final docs = [
      for (final d in a.docs)
        if (d.name == docName) d.toggle() else d,
    ];
    var stage = a.stage;
    if (a.stage == VisaStage.docsRequired && docs.every((d) => d.collected)) {
      stage = VisaStage.docsCollected;
    } else if (a.stage == VisaStage.docsCollected &&
        !docs.every((d) => d.collected)) {
      stage = VisaStage.docsRequired;
    }
    return _delayed(_replace(id, a.copyWith(docs: docs, stage: stage)));
  }

  @override
  Future<Result<VisaApplication>> moveStage(String id, VisaStage stage) {
    final a = _find(id);
    if (a == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(_replace(id, a.copyWith(stage: stage)));
  }

  @override
  Future<Result<VisaApplication>> submit(String id) {
    final a = _find(id);
    if (a == null) return _delayed(const Result.err(NotFoundFailure()));
    if (!a.allDocsCollected) {
      return _delayed(
        const Result.err(
          ValidationFailure('Collect every document before submitting.', {}),
        ),
      );
    }
    return _delayed(
      _replace(
        id,
        a.copyWith(stage: VisaStage.submitted, submittedAt: DateTime.now()),
      ),
    );
  }

  @override
  Future<Result<VisaApplication>> decide(String id, {required bool approved}) {
    final a = _find(id);
    if (a == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(
      _replace(
        id,
        a.copyWith(
          stage: approved ? VisaStage.approved : VisaStage.rejected,
          decisionAt: DateTime.now(),
        ),
      ),
    );
  }
}
