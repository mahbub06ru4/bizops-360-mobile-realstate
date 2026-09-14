import 'package:equatable/equatable.dart';

enum BookingKind { flight, hotel, package }

enum BookingStatus { held, ticketed, cancelled, completed }

class BookingSegment extends Equatable {
  const BookingSegment({
    required this.from,
    required this.to,
    required this.carrier,
    required this.flightNo,
    required this.departsAt,
  });

  final String from;
  final String to;
  final String carrier;
  final String flightNo;
  final DateTime departsAt;

  @override
  List<Object?> get props => [from, to, carrier, flightNo, departsAt];
}

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.reference,
    required this.travellerName,
    required this.kind,
    required this.status,
    required this.amount,
    required this.travelDate,
    this.segments = const [],
    this.hotelName,
    this.itinerary,
  });

  final String id;

  /// PNR / booking reference.
  final String reference;
  final String travellerName;
  final BookingKind kind;
  final BookingStatus status;

  /// BDT.
  final num amount;
  final DateTime travelDate;
  final List<BookingSegment> segments;
  final String? hotelName;
  final String? itinerary;

  bool get isActive =>
      status == BookingStatus.held || status == BookingStatus.ticketed;

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id,
    reference: reference,
    travellerName: travellerName,
    kind: kind,
    status: status ?? this.status,
    amount: amount,
    travelDate: travelDate,
    segments: segments,
    hotelName: hotelName,
    itinerary: itinerary,
  );

  @override
  List<Object?> get props => [
    id,
    reference,
    travellerName,
    kind,
    status,
    amount,
    travelDate,
    segments,
    hotelName,
    itinerary,
  ];
}
