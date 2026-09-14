import 'package:equatable/equatable.dart';

import 'amenity.dart';
import 'building.dart';
import 'payment_plan.dart';
import 'project_location.dart';
import 'project_pricing.dart';

/// The project's commercial structure (roadmap §1/§5).
enum ProjectType { landShare, apartment, commercial }

/// Admin verification workflow (roadmap §5 `verification_reviews`, Phase 0
/// keeps it a plain status on the project — the review-queue screen is
/// Phase 1+). A seller drafts, then submits; only `verified` is safe to show
/// publicly once a marketplace exists (Phase 3).
enum ProjectStatus { draft, submitted, verified, rejected }

/// The aggregate root for the real-estate vertical (roadmap §5
/// `real_estate_projects`), carrying its location, land/building structure,
/// amenities, pricing and payment plans as one buyer/seller-facing document.
class RealEstateProject extends Equatable {
  const RealEstateProject({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.description,
    this.location,
    this.buildings = const [],
    this.amenities = const [],
    this.pricing,
    this.paymentPlans = const [],
    this.contactName,
    this.contactPhone,
    this.createdAt,
  });

  final String id;
  final String title;
  final ProjectType type;
  final ProjectStatus status;
  final String? description;
  final ProjectLocation? location;
  final List<Building> buildings;
  final List<Amenity> amenities;
  final ProjectPricing? pricing;
  final List<PaymentPlan> paymentPlans;
  final String? contactName;
  final String? contactPhone;
  final DateTime? createdAt;

  /// Every unit across every building — a pure land-share project may instead
  /// keep its sellable inventory directly under a single implicit building,
  /// depending on how the seller modelled it in the wizard.
  int get unitCount => buildings.fold(0, (sum, b) => sum + b.units.length);

  bool get isEditable => status == ProjectStatus.draft;

  bool get canSubmit =>
      status == ProjectStatus.draft &&
      location != null &&
      title.trim().isNotEmpty;

  RealEstateProject copyWith({
    String? title,
    ProjectType? type,
    ProjectStatus? status,
    String? description,
    ProjectLocation? location,
    List<Building>? buildings,
    List<Amenity>? amenities,
    ProjectPricing? pricing,
    List<PaymentPlan>? paymentPlans,
    String? contactName,
    String? contactPhone,
  }) => RealEstateProject(
    id: id,
    title: title ?? this.title,
    type: type ?? this.type,
    status: status ?? this.status,
    description: description ?? this.description,
    location: location ?? this.location,
    buildings: buildings ?? this.buildings,
    amenities: amenities ?? this.amenities,
    pricing: pricing ?? this.pricing,
    paymentPlans: paymentPlans ?? this.paymentPlans,
    contactName: contactName ?? this.contactName,
    contactPhone: contactPhone ?? this.contactPhone,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    status,
    description,
    location,
    buildings,
    amenities,
    pricing,
    paymentPlans,
    contactName,
    contactPhone,
    createdAt,
  ];
}
