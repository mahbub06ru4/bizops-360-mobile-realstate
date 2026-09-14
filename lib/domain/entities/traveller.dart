import 'package:equatable/equatable.dart';

class Traveller extends Equatable {
  const Traveller({
    required this.id,
    required this.name,
    required this.nationality,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.passportNumber,
    this.passportExpiry,
    this.tripCount = 0,
  });

  final String id;
  final String name;
  final String nationality;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? passportNumber;
  final DateTime? passportExpiry;
  final int tripCount;

  bool get passportExpired =>
      passportExpiry != null && passportExpiry!.isBefore(DateTime.now());

  bool get passportExpiringSoon {
    final e = passportExpiry;
    if (e == null || passportExpired) return false;
    return e.difference(DateTime.now()).inDays <= 180;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nationality,
    phone,
    email,
    dateOfBirth,
    passportNumber,
    passportExpiry,
    tripCount,
  ];
}

class TravelHistoryEntry extends Equatable {
  const TravelHistoryEntry({
    required this.id,
    required this.destination,
    required this.date,
    required this.purpose,
  });

  final String id;
  final String destination;
  final DateTime date;
  final String purpose;

  @override
  List<Object?> get props => [id, destination, date, purpose];
}
