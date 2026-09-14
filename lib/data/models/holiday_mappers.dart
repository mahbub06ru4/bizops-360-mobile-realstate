import '../../domain/entities/holiday.dart';

/// `HolidayResource` ↔ [HolidayEntry]. Endpoint/field names are a best guess —
/// not yet confirmed against a running backend.
HolidayEntry holidayFromJson(Map<String, dynamic> json) {
  return HolidayEntry(
    id: json['id'].toString(),
    name: json['name'] as String? ?? json['title'] as String? ?? '',
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
  );
}
