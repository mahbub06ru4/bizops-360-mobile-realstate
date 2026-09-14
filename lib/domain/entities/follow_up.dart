import 'package:equatable/equatable.dart';

enum FollowUpChannel { call, whatsapp, email, meeting, visit }

enum FollowUpOutcome { reached, noAnswer, rescheduled, notInterested, won }

class FollowUp extends Equatable {
  const FollowUp({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.dueAt,
    required this.channel,
    required this.note,
    this.done = false,
    this.outcome,
  });

  final String id;
  final String customerId;
  final String customerName;
  final DateTime dueAt;
  final FollowUpChannel channel;
  final String note;
  final bool done;
  final FollowUpOutcome? outcome;

  bool get isOverdue {
    if (done) return false;
    final now = DateTime.now();
    return dueAt.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool isDueToday() {
    final now = DateTime.now();
    return dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }

  FollowUp complete(FollowUpOutcome outcome) => FollowUp(
    id: id,
    customerId: customerId,
    customerName: customerName,
    dueAt: dueAt,
    channel: channel,
    note: note,
    done: true,
    outcome: outcome,
  );

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerName,
    dueAt,
    channel,
    note,
    done,
    outcome,
  ];
}
