import 'package:flutter/material.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/booking.dart';

extension BookingKindDisplay on BookingKind {
  String get labelKey => switch (this) {
    BookingKind.flight => Tr.bkKindFlight,
    BookingKind.hotel => Tr.bkKindHotel,
    BookingKind.package => Tr.bkKindPackage,
  };

  IconData get icon => switch (this) {
    BookingKind.flight => Icons.flight,
    BookingKind.hotel => Icons.hotel,
    BookingKind.package => Icons.luggage,
  };
}

extension BookingStatusDisplay on BookingStatus {
  String get labelKey => switch (this) {
    BookingStatus.held => Tr.bkStatusHeld,
    BookingStatus.ticketed => Tr.bkStatusTicketed,
    BookingStatus.cancelled => Tr.bkStatusCancelled,
    BookingStatus.completed => Tr.bkStatusCompleted,
  };

  ChipTone get tone => switch (this) {
    BookingStatus.held => ChipTone.signal,
    BookingStatus.ticketed => ChipTone.brand,
    BookingStatus.cancelled => ChipTone.critical,
    BookingStatus.completed => ChipTone.neutral,
  };
}
