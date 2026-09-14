import 'package:flutter/material.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/property_match.dart';
import '../../domain/entities/property_requirement.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/entities/site_visit.dart';

/// Shared display helpers (label keys, chip tones) for the Phase 1 sales
/// pipeline — `requirements/`, `site_visits/`, `offers/`, `re_bookings/` all
/// import this one file, mirroring `project_display.dart` for Phase 0.

extension RequirementPurposeDisplay on RequirementPurpose {
  String get labelKey => switch (this) {
    RequirementPurpose.buy => Tr.reqPurposeBuy,
    RequirementPurpose.invest => Tr.reqPurposeInvest,
  };
}

extension PropertyMatchStatusDisplay on PropertyMatchStatus {
  String get labelKey => switch (this) {
    PropertyMatchStatus.suggested => Tr.matchStatusSuggested,
    PropertyMatchStatus.viewed => Tr.matchStatusViewed,
    PropertyMatchStatus.interested => Tr.matchStatusInterested,
    PropertyMatchStatus.rejected => Tr.matchStatusRejected,
  };

  ChipTone get tone => switch (this) {
    PropertyMatchStatus.suggested => ChipTone.neutral,
    PropertyMatchStatus.viewed => ChipTone.signal,
    PropertyMatchStatus.interested => ChipTone.brand,
    PropertyMatchStatus.rejected => ChipTone.critical,
  };
}

extension SiteVisitStatusDisplay on SiteVisitStatus {
  String get labelKey => switch (this) {
    SiteVisitStatus.scheduled => Tr.svStatusScheduled,
    SiteVisitStatus.completed => Tr.svStatusCompleted,
    SiteVisitStatus.cancelled => Tr.svStatusCancelled,
    SiteVisitStatus.noShow => Tr.svStatusNoShow,
  };

  ChipTone get tone => switch (this) {
    SiteVisitStatus.scheduled => ChipTone.signal,
    SiteVisitStatus.completed => ChipTone.brand,
    SiteVisitStatus.cancelled => ChipTone.neutral,
    SiteVisitStatus.noShow => ChipTone.critical,
  };
}

extension OfferStatusDisplay on OfferStatus {
  String get labelKey => switch (this) {
    OfferStatus.pending => Tr.offerStatusPending,
    OfferStatus.countered => Tr.offerStatusCountered,
    OfferStatus.accepted => Tr.offerStatusAccepted,
    OfferStatus.rejected => Tr.offerStatusRejected,
    OfferStatus.expired => Tr.offerStatusExpired,
  };

  ChipTone get tone => switch (this) {
    OfferStatus.pending => ChipTone.signal,
    OfferStatus.countered => ChipTone.info,
    OfferStatus.accepted => ChipTone.brand,
    OfferStatus.rejected => ChipTone.critical,
    OfferStatus.expired => ChipTone.neutral,
  };
}

extension OfferPartyDisplay on OfferParty {
  String get labelKey => switch (this) {
    OfferParty.buyer => Tr.offerByBuyer,
    OfferParty.seller => Tr.offerBySeller,
  };

  IconData get icon => switch (this) {
    OfferParty.buyer => Icons.person_outline,
    OfferParty.seller => Icons.storefront_outlined,
  };
}

extension RealEstateBookingStatusDisplay on RealEstateBookingStatus {
  String get labelKey => switch (this) {
    RealEstateBookingStatus.reserved => Tr.bookStatusReserved,
    RealEstateBookingStatus.booked => Tr.bookStatusBooked,
    RealEstateBookingStatus.cancelled => Tr.bookStatusCancelled,
    RealEstateBookingStatus.completed => Tr.bookStatusCompleted,
  };

  ChipTone get tone => switch (this) {
    RealEstateBookingStatus.reserved => ChipTone.signal,
    RealEstateBookingStatus.booked => ChipTone.brand,
    RealEstateBookingStatus.cancelled => ChipTone.neutral,
    RealEstateBookingStatus.completed => ChipTone.brand,
  };
}

extension InstallmentStatusDisplay on InstallmentStatus {
  String get labelKey => switch (this) {
    InstallmentStatus.pending => Tr.instStatusPending,
    InstallmentStatus.invoiced => Tr.instStatusInvoiced,
    InstallmentStatus.paid => Tr.instStatusPaid,
    InstallmentStatus.overdue => Tr.instStatusOverdue,
  };

  ChipTone get tone => switch (this) {
    InstallmentStatus.pending => ChipTone.neutral,
    InstallmentStatus.invoiced => ChipTone.signal,
    InstallmentStatus.paid => ChipTone.brand,
    InstallmentStatus.overdue => ChipTone.critical,
  };
}
