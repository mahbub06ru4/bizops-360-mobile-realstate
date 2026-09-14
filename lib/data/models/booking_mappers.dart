import '../../domain/entities/booking.dart';

/// `BookingResource` ↔ [Booking].
///
/// Backend `type` covers eight products; the app's three kinds fold the rest
/// into `package`. Backend `status` is `quoted | confirmed | ticketed |
/// completed | cancelled | refunded`.
const Map<String, BookingKind> _kindFromApi = {
  'air_ticket': BookingKind.flight,
  'hotel': BookingKind.hotel,
  'tour_package': BookingKind.package,
};

const Map<BookingKind, String> bookingKindToApi = {
  BookingKind.flight: 'air_ticket',
  BookingKind.hotel: 'hotel',
  BookingKind.package: 'tour_package',
};

const Map<String, BookingStatus> _statusFromApi = {
  'quoted': BookingStatus.held,
  'confirmed': BookingStatus.held,
  'ticketed': BookingStatus.ticketed,
  'completed': BookingStatus.completed,
  'cancelled': BookingStatus.cancelled,
  'refunded': BookingStatus.cancelled,
};

num _money(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

DateTime _date(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();

String? _firstPassengerName(dynamic passengers) {
  if (passengers is! List || passengers.isEmpty) return null;
  final first = passengers.first;
  if (first is! Map) return null;
  final traveller = first['traveller'];
  return traveller is Map ? traveller['full_name'] as String? : null;
}

Booking bookingFromJson(Map<String, dynamic> json) {
  final customer = json['customer'];
  final segments = json['segments'];
  final hotelStays = json['hotel_stays'];
  final itinerary = json['itinerary'];

  final firstPassengerName = _firstPassengerName(json['passengers']);

  return Booking(
    id: json['id'].toString(),
    reference: json['pnr'] as String? ?? json['reference'] as String? ?? '',
    travellerName:
        firstPassengerName ??
        (customer is Map ? customer['name'] as String? : null) ??
        json['title'] as String? ??
        '',
    kind: _kindFromApi[json['type']] ?? BookingKind.package,
    status: _statusFromApi[json['status']] ?? BookingStatus.held,
    amount: _money(json['sell_amount']),
    travelDate: _date(json['depart_on']),
    segments: segments is List
        ? segments
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (s) => BookingSegment(
                  from: s['from_airport'] as String? ?? '',
                  to: s['to_airport'] as String? ?? '',
                  carrier: s['airline'] as String? ?? '',
                  flightNo: s['flight_number'] as String? ?? '',
                  departsAt: _date(s['depart_at']),
                ),
              )
              .toList(growable: false)
        : const [],
    hotelName: hotelStays is List && hotelStays.isNotEmpty
        ? (hotelStays.first as Map)['hotel_name'] as String?
        : null,
    itinerary: itinerary is List && itinerary.isNotEmpty
        ? itinerary
              .whereType<Map<dynamic, dynamic>>()
              .map((i) => i['title'] as String? ?? '')
              .where((t) => t.isNotEmpty)
              .join(' · ')
        : null,
  );
}
