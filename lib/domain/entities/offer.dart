import 'package:equatable/equatable.dart';

/// Who proposed a particular offer/counter in the negotiation chain.
enum OfferParty { buyer, seller }

enum OfferStatus { pending, countered, accepted, rejected, expired }

/// One node in a structured negotiation chain (roadmap §7 — "structured
/// Offer, not chat"). A counter-offer is a *new* [Offer] with
/// [previousOfferId] pointing at the one it responds to, so the full
/// offer -> counter -> counter -> accepted/rejected history renders as a
/// simple linked list, newest last. [projectId]/[projectTitle] are derived
/// from the embedded unit's own `project_id`/`project_name` (the backend has
/// no separate project embed on an offer).
class Offer extends Equatable {
  const Offer({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.unitId,
    required this.unitName,
    required this.offeredPrice,
    required this.offeredBy,
    required this.status,
    this.projectId = '',
    this.projectTitle = '',
    this.previousOfferId,
    this.notes,
    this.counterOffers = const [],
    this.createdAt,
  });

  final String id;
  final String leadId;
  final String leadName;
  final String projectId;
  final String projectTitle;
  final String unitId;
  final String unitName;

  /// BDT.
  final num offeredPrice;
  final OfferParty offeredBy;
  final OfferStatus status;

  /// The offer this one counters — null for the thread's opening offer.
  final String? previousOfferId;
  final String? notes;

  /// This offer's own counters — only ever populated when the offer was
  /// fetched via `GET /offers/{id}` (the `show` endpoint); empty on every
  /// other response.
  final List<Offer> counterOffers;

  final DateTime? createdAt;

  bool get isLatestActionable =>
      status == OfferStatus.pending || status == OfferStatus.countered;

  @override
  List<Object?> get props => [
    id,
    leadId,
    leadName,
    projectId,
    projectTitle,
    unitId,
    unitName,
    offeredPrice,
    offeredBy,
    status,
    previousOfferId,
    notes,
    counterOffers,
    createdAt,
  ];
}
