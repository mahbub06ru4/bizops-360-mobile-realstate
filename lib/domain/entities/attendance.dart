import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, late, earlyLeave, absent, onLeave, holiday }

/// Where a punch was made from, relative to the office geofence.
enum PunchZone { office, outside }

/// A single day's attendance record.
class AttendanceDay extends Equatable {
  const AttendanceDay({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.checkInZone,
    this.checkOutZone,
  });

  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final PunchZone? checkInZone;
  final PunchZone? checkOutZone;

  Duration? get worked => (checkIn != null && checkOut != null)
      ? checkOut!.difference(checkIn!)
      : null;

  @override
  List<Object?> get props => [
    date,
    status,
    checkIn,
    checkOut,
    checkInZone,
    checkOutZone,
  ];
}

/// Today's live state — drives the check-in / check-out card.
class AttendanceToday extends Equatable {
  const AttendanceToday({
    this.checkIn,
    this.checkOut,
    this.checkInZone,
    this.checkOutZone,
  });

  final DateTime? checkIn;
  final DateTime? checkOut;
  final PunchZone? checkInZone;
  final PunchZone? checkOutZone;

  bool get isCheckedIn => checkIn != null && checkOut == null;
  bool get isDone => checkIn != null && checkOut != null;

  AttendanceToday copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    PunchZone? checkInZone,
    PunchZone? checkOutZone,
  }) => AttendanceToday(
    checkIn: checkIn ?? this.checkIn,
    checkOut: checkOut ?? this.checkOut,
    checkInZone: checkInZone ?? this.checkInZone,
    checkOutZone: checkOutZone ?? this.checkOutZone,
  );

  @override
  List<Object?> get props => [checkIn, checkOut, checkInZone, checkOutZone];
}
