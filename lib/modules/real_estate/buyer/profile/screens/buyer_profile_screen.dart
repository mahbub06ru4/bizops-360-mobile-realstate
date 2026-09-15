import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/localization/translation_keys.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';
import '../controllers/buyer_profile_controller.dart';

class BuyerProfileScreen extends GetView<BuyerProfileController> {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(Tr.buyerProfileTitle.tr)),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          if (user != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(name: user.name),
                      SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(user.name, style: text.titleMedium)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  _row(context, Icons.email_outlined, user.email),
                  if (user.phone != null)
                    _row(context, Icons.phone_outlined, user.phone!),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
          AppButton(
            label: Tr.buyerSignOut.tr,
            variant: AppButtonVariant.secondary,
            onPressed: controller.signOut,
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
