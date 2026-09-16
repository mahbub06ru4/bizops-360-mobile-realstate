import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/state/async_value.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/installment.dart';
import '../../../domain/entities/real_estate_booking.dart';
import '../../../domain/entities/real_estate_project.dart';
import '../../../domain/entities/unit.dart';
import '../../../domain/repositories/real_estate_booking_repository.dart';
import '../../../domain/repositories/real_estate_project_repository.dart';
import '../../../presentation/home/widgets/dashboard_section.dart';
import '../offers/bindings/offers_binding.dart';
import '../projects/bindings/real_estate_bindings.dart';

/// Home dashboard: a per-tenant sales / collections / inventory snapshot
/// (roadmap §7 Phase 3 — "per-tenant sales/collections/inventory
/// dashboards"). Every number here is computed client-side from lists this
/// app already fetches via [RealEstateBookingRepository] /
/// [RealEstateProjectRepository] — there is no backend aggregate endpoint
/// for this yet (unlike Travel's server-side `travel/overview`); a future
/// `GET /real-estate/overview` would let this move server-side without
/// changing this widget's shape.
class SalesOverviewSection extends StatefulWidget {
  const SalesOverviewSection({super.key});

  @override
  State<SalesOverviewSection> createState() => _SalesOverviewSectionState();
}

class _Overview {
  const _Overview({
    required this.bookingsThisMonth,
    required this.agreedValueThisMonth,
    required this.collectedThisMonth,
    required this.pendingOrOverdue,
    required this.available,
    required this.reserved,
    required this.sold,
  });

  final int bookingsThisMonth;
  final num agreedValueThisMonth;
  final num collectedThisMonth;
  final num pendingOrOverdue;
  final int available;
  final int reserved;
  final int sold;
}

class _SalesOverviewSectionState extends State<SalesOverviewSection> {
  late final Rx<AsyncValue<_Overview>> _state =
      const AsyncValue<_Overview>.loading().obs;

  @override
  void initState() {
    super.initState();
    ensureRealEstateProjectRepo();
    ensureRealEstateBookingRepo();
    _load();
  }

  Future<void> _load() async {
    _state.value = const AsyncValue.loading();
    final bookingsRepo = Get.find<RealEstateBookingRepository>();
    final projectsRepo = Get.find<RealEstateProjectRepository>();

    final bookingsResult = await bookingsRepo.list();
    final projectsResult = await projectsRepo.list();

    if (bookingsResult.isErr) {
      _state.value = AsyncValue.error(bookingsResult.failureOrNull!);
      return;
    }
    if (projectsResult.isErr) {
      _state.value = AsyncValue.error(projectsResult.failureOrNull!);
      return;
    }

    final bookings = bookingsResult.valueOrNull ?? const <RealEstateBooking>[];
    final projects = projectsResult.valueOrNull ?? const <RealEstateProject>[];

    final now = DateTime.now();
    bool isThisMonth(DateTime? d) =>
        d != null && d.year == now.year && d.month == now.month;

    final bookingsThisMonth = bookings
        .where((b) => isThisMonth(b.createdAt))
        .toList(growable: false);
    final agreedValueThisMonth = bookingsThisMonth.fold<num>(
      0,
      (sum, b) => sum + b.agreedPrice,
    );

    num collected = 0;
    num pendingOrOverdue = 0;
    for (final booking in bookings) {
      final planResult = await bookingsRepo.planFor(booking.id);
      final plan = planResult.valueOrNull;
      if (plan == null) continue;
      final installmentsResult = await bookingsRepo.installmentsFor(plan.id);
      final installments =
          installmentsResult.valueOrNull ?? const <Installment>[];
      for (final installment in installments) {
        if (installment.status == InstallmentStatus.paid) {
          if (isThisMonth(installment.dueDate)) collected += installment.amount;
        } else {
          pendingOrOverdue += installment.amount;
        }
      }
    }

    var available = 0;
    var reserved = 0;
    var sold = 0;
    for (final project in projects) {
      for (final building in project.buildings) {
        for (final unit in building.units) {
          switch (unit.status) {
            case UnitStatus.available:
              available++;
            case UnitStatus.reserved:
              reserved++;
            case UnitStatus.sold:
              sold++;
          }
        }
      }
    }

    _state.value = AsyncValue.data(
      _Overview(
        bookingsThisMonth: bookingsThisMonth.length,
        agreedValueThisMonth: agreedValueThisMonth,
        collectedThisMonth: collected,
        pendingOrOverdue: pendingOrOverdue,
        available: available,
        reserved: reserved,
        sold: sold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final overview = _state.value.valueOrNull;
      if (overview == null) return const SizedBox.shrink();

      return DashboardSection(
        title: Tr.homeSalesOverview.tr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetricRow(
              label: Tr.homeSalesBookings.tr,
              value: overview.bookingsThisMonth.toString(),
              trailing: overview.agreedValueThisMonth.toBdt(decimals: false),
            ),
            const Divider(height: 1),
            _MetricRow(
              label: Tr.homeSalesCollected.tr,
              value: overview.collectedThisMonth.toBdt(decimals: false),
              trailing: overview.pendingOrOverdue > 0
                  ? Tr.homeSalesPending.trParams({
                      'amount': overview.pendingOrOverdue.toBdt(
                        decimals: false,
                      ),
                    })
                  : null,
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: _InventoryChip(
                      label: Tr.homeInventoryAvailable.tr,
                      count: overview.available,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InventoryChip(
                      label: Tr.homeInventoryReserved.tr,
                      count: overview.reserved,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InventoryChip(
                      label: Tr.homeInventorySold.tr,
                      count: overview.sold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodyMedium)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: text.bodySmall?.copyWith(color: c.inkMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryChip extends StatelessWidget {
  const _InventoryChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label, style: text.bodySmall?.copyWith(color: c.inkMuted)),
        ],
      ),
    );
  }
}
