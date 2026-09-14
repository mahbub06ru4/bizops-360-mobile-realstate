import 'package:equatable/equatable.dart';

class HolidayEntry extends Equatable {
  const HolidayEntry({
    required this.id,
    required this.name,
    required this.date,
  });

  final String id;
  final String name;
  final DateTime date;

  bool get isPast {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  List<Object?> get props => [id, name, date];
}
