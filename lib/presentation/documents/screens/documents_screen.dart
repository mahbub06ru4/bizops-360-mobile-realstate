import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/document_item.dart';
import '../controllers/documents_controller.dart';
import '../document_display.dart';

class DocumentsScreen extends GetView<DocumentsController> {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.wsDocuments.tr)),
      body: Column(
        children: [
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                      label: Text(
                        '${Tr.docExpiring.tr} ${controller.expiringCount}',
                      ),
                      selected: controller.expiringOnly.value,
                      onSelected: (v) => controller.expiringOnly.value = v,
                    ),
                  ),
                  for (final cat in DocumentCategory.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(cat.labelKey.tr),
                        selected: controller.category.value == cat,
                        onSelected: (_) => controller.toggleCategory(cat),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(
                () => AsyncView<List<DocumentItem>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  data: (_) {
                    final list = controller.visible;
                    if (list.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          const AppEmptyState(),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _DocRow(doc: list[i]),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.doc});

  final DocumentItem doc;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    String? expiry;
    ChipTone? tone;
    if (doc.isExpired) {
      expiry = Tr.docExpired.tr;
      tone = ChipTone.critical;
    } else if (doc.expiresSoon) {
      expiry =
          '${Tr.docExpires.tr} ${DateFormat.MMMd().format(doc.expiresAt!)}';
      tone = ChipTone.signal;
    }

    return ListTile(
      leading: Icon(doc.category.icon, color: c.inkMuted),
      title: Text(doc.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${doc.ownerName} · ${DateFormat.MMMd().format(doc.uploadedAt)}'
        '${doc.sizeLabel == null ? '' : ' · ${doc.sizeLabel}'}',
        style: text.bodySmall,
      ),
      trailing: expiry == null
          ? const Icon(Icons.download_outlined, size: 20)
          : AppStatusChip(expiry, tone: tone!, dot: false),
      onTap: () {},
    );
  }
}
