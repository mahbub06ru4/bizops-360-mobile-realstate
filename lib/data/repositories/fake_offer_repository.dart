import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/offer_repository.dart';

/// In-memory negotiation threads for UI-first development. Seeded with one
/// completed thread (offer -> counter -> accepted) for lead `c2` / unit
/// `rp2`/`u3`, matching the site-visit and booking fakes' demo story.
class FakeOfferRepository implements OfferRepository {
  FakeOfferRepository() : _items = _seed();

  List<Offer> _items;
  var _nextId = 800;

  static DateTime _ago(int days) =>
      DateTime.now().subtract(Duration(days: days));

  static List<Offer> _seed() => [
    Offer(
      id: 'o1',
      leadId: 'c2',
      leadName: 'Nusrat Jahan',
      unitId: 'u3',
      unitName: 'A-3B',
      projectId: 'rp2',
      projectTitle: 'Khulshi Heights',
      offeredPrice: 14500000,
      offeredBy: OfferParty.seller,
      status: OfferStatus.countered,
      createdAt: _ago(6),
    ),
    Offer(
      id: 'o2',
      leadId: 'c2',
      leadName: 'Nusrat Jahan',
      unitId: 'u3',
      unitName: 'A-3B',
      projectId: 'rp2',
      projectTitle: 'Khulshi Heights',
      offeredPrice: 13200000,
      offeredBy: OfferParty.buyer,
      status: OfferStatus.countered,
      previousOfferId: 'o1',
      notes: 'Wants a discount for full down payment.',
      createdAt: _ago(5),
    ),
    Offer(
      id: 'o3',
      leadId: 'c2',
      leadName: 'Nusrat Jahan',
      unitId: 'u3',
      unitName: 'A-3B',
      projectId: 'rp2',
      projectTitle: 'Khulshi Heights',
      offeredPrice: 13800000,
      offeredBy: OfferParty.seller,
      status: OfferStatus.accepted,
      previousOfferId: 'o2',
      notes: 'Meeting in the middle.',
      createdAt: _ago(4),
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  Offer? _find(String id) => _items.where((o) => o.id == id).firstOrNull;

  @override
  Future<Result<List<Offer>>> latestPerThread() {
    // One row per thread: an offer that nothing else points back to via
    // `previousOfferId` is the current head of its chain.
    final referenced = _items
        .map((o) => o.previousOfferId)
        .whereType<String>()
        .toSet();
    final heads = _items.where((o) => !referenced.contains(o.id)).toList()
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    return _delayed(Result.ok(List.unmodifiable(heads)));
  }

  @override
  Future<Result<List<Offer>>> history(String offerId) {
    // Walk `previousOfferId` backward from [offerId] to the thread's
    // opening offer, mirroring how the real repository reconstructs it from
    // `GET /offers/{id}` calls (no dedicated history endpoint exists).
    final byId = {for (final o in _items) o.id: o};
    final chain = <Offer>[];
    String? cursor = offerId;
    final seen = <String>{};
    while (cursor != null && seen.add(cursor)) {
      final node = byId[cursor];
      if (node == null) break;
      chain.add(node);
      cursor = node.previousOfferId;
    }
    return _delayed(Result.ok(chain.reversed.toList(growable: false)));
  }

  @override
  Future<Result<Offer>> getById(String id) {
    final o = _find(id);
    return _delayed(
      o == null ? const Result.err(NotFoundFailure()) : Result.ok(o),
    );
  }

  @override
  Future<Result<Offer>> makeOffer({
    required String leadId,
    required String leadName,
    required String unitId,
    required num offeredPrice,
    String? unitName,
    String? projectId,
    String? projectTitle,
    OfferParty? offeredBy,
    String? notes,
  }) {
    final offer = Offer(
      id: 'o${_nextId++}',
      leadId: leadId,
      leadName: leadName,
      unitId: unitId,
      unitName: unitName ?? '',
      projectId: projectId ?? '',
      projectTitle: projectTitle ?? '',
      offeredPrice: offeredPrice,
      offeredBy: offeredBy ?? OfferParty.seller,
      status: OfferStatus.pending,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _items = [...(_items), offer];
    return _delayed(Result.ok(offer));
  }

  @override
  Future<Result<Offer>> counter(
    String offerId, {
    required num offeredPrice,
    OfferParty? offeredBy,
    String? notes,
  }) {
    final prev = _find(offerId);
    if (prev == null) return _delayed(const Result.err(NotFoundFailure()));
    if (!prev.isLatestActionable) {
      return _delayed(
        const Result.err(
          ValidationFailure('This offer is no longer active.', {}),
        ),
      );
    }
    final countered = Offer(
      id: 'o${_nextId++}',
      leadId: prev.leadId,
      leadName: prev.leadName,
      unitId: prev.unitId,
      unitName: prev.unitName,
      projectId: prev.projectId,
      projectTitle: prev.projectTitle,
      offeredPrice: offeredPrice,
      offeredBy: offeredBy ?? _flip(prev.offeredBy),
      status: OfferStatus.countered,
      previousOfferId: prev.id,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _items = [
      for (final o in _items)
        if (o.id == prev.id) _asCountered(o) else o,
      countered,
    ];
    return _delayed(Result.ok(countered));
  }

  OfferParty _flip(OfferParty p) =>
      p == OfferParty.buyer ? OfferParty.seller : OfferParty.buyer;

  Offer _asCountered(Offer o) => Offer(
    id: o.id,
    leadId: o.leadId,
    leadName: o.leadName,
    unitId: o.unitId,
    unitName: o.unitName,
    projectId: o.projectId,
    projectTitle: o.projectTitle,
    offeredPrice: o.offeredPrice,
    offeredBy: o.offeredBy,
    status: OfferStatus.countered,
    previousOfferId: o.previousOfferId,
    notes: o.notes,
    createdAt: o.createdAt,
  );

  @override
  Future<Result<Offer>> accept(String offerId) {
    final o = _find(offerId);
    if (o == null) return _delayed(const Result.err(NotFoundFailure()));
    final accepted = Offer(
      id: o.id,
      leadId: o.leadId,
      leadName: o.leadName,
      unitId: o.unitId,
      unitName: o.unitName,
      projectId: o.projectId,
      projectTitle: o.projectTitle,
      offeredPrice: o.offeredPrice,
      offeredBy: o.offeredBy,
      status: OfferStatus.accepted,
      previousOfferId: o.previousOfferId,
      notes: o.notes,
      createdAt: o.createdAt,
    );
    _items = [
      for (final x in _items)
        if (x.id == offerId) accepted else x,
    ];
    return _delayed(Result.ok(accepted));
  }

  @override
  Future<Result<Offer>> reject(String offerId) {
    final o = _find(offerId);
    if (o == null) return _delayed(const Result.err(NotFoundFailure()));
    final rejected = Offer(
      id: o.id,
      leadId: o.leadId,
      leadName: o.leadName,
      unitId: o.unitId,
      unitName: o.unitName,
      projectId: o.projectId,
      projectTitle: o.projectTitle,
      offeredPrice: o.offeredPrice,
      offeredBy: o.offeredBy,
      status: OfferStatus.rejected,
      previousOfferId: o.previousOfferId,
      notes: o.notes,
      createdAt: o.createdAt,
    );
    _items = [
      for (final x in _items)
        if (x.id == offerId) rejected else x,
    ];
    return _delayed(Result.ok(rejected));
  }
}
