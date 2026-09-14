import 'package:flutter/material.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/real_estate_project.dart';
import '../../../domain/entities/unit.dart';

extension ProjectTypeDisplay on ProjectType {
  String get labelKey => switch (this) {
    ProjectType.landShare => Tr.projTypeLandShare,
    ProjectType.apartment => Tr.projTypeApartment,
    ProjectType.commercial => Tr.projTypeCommercial,
  };

  IconData get icon => switch (this) {
    ProjectType.landShare => Icons.landscape_outlined,
    ProjectType.apartment => Icons.apartment_outlined,
    ProjectType.commercial => Icons.storefront_outlined,
  };
}

extension ProjectStatusDisplay on ProjectStatus {
  String get labelKey => switch (this) {
    ProjectStatus.draft => Tr.projStatusDraft,
    ProjectStatus.submitted => Tr.projStatusSubmitted,
    ProjectStatus.verified => Tr.projStatusVerified,
    ProjectStatus.rejected => Tr.projStatusRejected,
  };

  ChipTone get tone => switch (this) {
    ProjectStatus.draft => ChipTone.neutral,
    ProjectStatus.submitted => ChipTone.signal,
    ProjectStatus.verified => ChipTone.brand,
    ProjectStatus.rejected => ChipTone.critical,
  };
}

extension UnitStatusDisplay on UnitStatus {
  String get labelKey => switch (this) {
    UnitStatus.available => Tr.unitStatusAvailable,
    UnitStatus.reserved => Tr.unitStatusReserved,
    UnitStatus.sold => Tr.unitStatusSold,
  };

  ChipTone get tone => switch (this) {
    UnitStatus.available => ChipTone.brand,
    UnitStatus.reserved => ChipTone.signal,
    UnitStatus.sold => ChipTone.neutral,
  };
}

extension UnitFacingDisplay on UnitFacing {
  String get labelKey => switch (this) {
    UnitFacing.north => Tr.unitFacingNorth,
    UnitFacing.south => Tr.unitFacingSouth,
    UnitFacing.east => Tr.unitFacingEast,
    UnitFacing.west => Tr.unitFacingWest,
    UnitFacing.northeast => Tr.unitFacingNortheast,
    UnitFacing.northwest => Tr.unitFacingNorthwest,
    UnitFacing.southeast => Tr.unitFacingSoutheast,
    UnitFacing.southwest => Tr.unitFacingSouthwest,
  };
}

/// Icon for an [Amenity.icon] hint — unknown keys fall back to a generic mark.
IconData amenityIcon(String? key) => switch (key) {
  'lift' => Icons.elevator_outlined,
  'generator' => Icons.bolt_outlined,
  'parking' => Icons.local_parking_outlined,
  'security' => Icons.security_outlined,
  'mosque' => Icons.mosque_outlined,
  'park' => Icons.park_outlined,
  'gym' => Icons.fitness_center_outlined,
  'community_hall' => Icons.groups_outlined,
  _ => Icons.check_circle_outline,
};
