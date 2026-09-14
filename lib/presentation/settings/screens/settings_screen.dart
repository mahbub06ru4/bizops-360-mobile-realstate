import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/settings/settings_controller.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final auth = Get.find<AuthController>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(Tr.settingsTitle.tr)),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionLabel(Tr.settingsAppearance.tr),
          Obx(
            () => SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(Tr.settingsThemeSystem.tr),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(Tr.settingsThemeLight.tr),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(Tr.settingsThemeDark.tr),
                ),
              ],
              selected: {settings.themeMode.value},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          AppSectionLabel(Tr.settingsLanguage.tr),
          Obx(
            () => SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'bn', label: Text('বাংলা')),
              ],
              selected: {settings.locale.value.languageCode},
              onSelectionChanged: (s) => settings.setLocale(
                s.first == 'bn'
                    ? AppTranslations.bengali
                    : AppTranslations.english,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: Tr.signOut.tr,
            onPressed: auth.signOut,
            variant: AppButtonVariant.secondary,
            icon: Icons.logout,
          ),
          SizedBox(height: AppSpacing.md),
          Center(child: Text('BizOps 360 · v1.0.0', style: text.bodySmall)),
        ],
      ),
    );
  }
}
