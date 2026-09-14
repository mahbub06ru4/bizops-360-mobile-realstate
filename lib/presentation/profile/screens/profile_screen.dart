import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';

/// My profile. Editing + app-lock land later; for now it shows the session
/// identity and roles.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(Tr.wsProfile.tr)),
      body: user == null
          ? const AppEmptyState()
          : ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                Center(child: AppAvatar(name: user.name, size: 72)),
                SizedBox(height: AppSpacing.md),
                Center(child: Text(user.name, style: text.headlineSmall)),
                Center(child: Text(user.email, style: text.bodyMedium)),
                SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final role in user.roles)
                      AppStatusChip(role, dot: false),
                  ],
                ),
              ],
            ),
    );
  }
}
