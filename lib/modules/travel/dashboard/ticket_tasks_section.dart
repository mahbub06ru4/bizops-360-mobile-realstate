import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/state/async_value.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../presentation/home/widgets/dashboard_section.dart';
import '../bookings/bindings/bookings_bindings.dart';

/// Home dashboard: the soonest upcoming departures. Reuses `BookingRepository`
/// (registered permanent on first use, fake or live per `Env.useFakeData`) —
/// no dedicated controller, just a one-shot fetch on first build.
class TicketTasksSection extends StatefulWidget {
  const TicketTasksSection({super.key});

  @override
  State<TicketTasksSection> createState() => _TicketTasksSectionState();
}

class _TicketTasksSectionState extends State<TicketTasksSection> {
  static const _maxRows = 3;

  late final Rx<AsyncValue<List<Booking>>> _state =
      const AsyncValue<List<Booking>>.loading().obs;

  @override
  void initState() {
    super.initState();
    ensureBookingRepo();
    _load();
  }

  Future<void> _load() async {
    final result = await Get.find<BookingRepository>().departures();
    _state.value = result.fold(AsyncValue.data, AsyncValue.error);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final upcoming = _state.value.valueOrNull ?? const <Booking>[];
      if (upcoming.isEmpty) return const SizedBox.shrink();

      return DashboardSection(
        title: Tr.homeTicketTasks.tr,
        onViewAll: () => Get.toNamed<void>(Routes.departures),
        child: Column(
          children: [
            for (var i = 0; i < upcoming.length.clamp(0, _maxRows); i++) ...[
              if (i > 0) const Divider(height: 1),
              _Row(booking: upcoming[i]),
            ],
          ],
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final seg = booking.segments.isNotEmpty ? booking.segments.first : null;

    return InkWell(
      onTap: () => Get.toNamed<void>(Routes.bookingDetail, arguments: booking),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                seg == null
                    ? booking.travellerName
                    : '${seg.from} → ${seg.to} · ${booking.travellerName}',
                style: text.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              DateFormat.MMMd().format(booking.travelDate),
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
