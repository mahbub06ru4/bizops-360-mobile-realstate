import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/booking.dart';
import '../controllers/departures_controller.dart';

class DeparturesScreen extends GetView<DeparturesController> {
  const DeparturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.departuresTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Booking>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            data: (_) {
              final groups = controller.grouped;
              return ListView(
                padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                children: [
                  for (final g in groups) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: AppSectionLabel(
                        DateFormat.MMMMEEEEd().format(g.day),
                      ),
                    ),
                    for (final b in g.bookings) _DepartureRow(booking: b),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DepartureRow extends StatelessWidget {
  const _DepartureRow({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final seg = booking.segments.isNotEmpty ? booking.segments.first : null;

    return ListTile(
      leading: Text(
        seg == null ? '--:--' : DateFormat.Hm().format(seg.departsAt),
        style: AppTypography.mono(c.ink, size: 14),
      ),
      title: Text(
        seg == null
            ? booking.travellerName
            : '${seg.from} → ${seg.to}  ·  ${seg.carrier} ${seg.flightNo}',
        style: text.bodyLarge,
      ),
      subtitle: Text('${booking.travellerName} · ${booking.reference}'),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => Get.toNamed<void>(Routes.bookingDetail, arguments: booking),
    );
  }
}
