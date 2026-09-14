import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../application/settings/settings_controller.dart';
import '../core/localization/app_translations.dart';
import '../core/localization/translation_keys.dart';
import '../core/routing/app_pages.dart';
import '../core/theme/app_theme.dart';

class BizOpsApp extends StatelessWidget {
  const BizOpsApp({super.key});

  /// Reference canvas from the approved mockup — every `.w` / `.h` / `.sp` /
  /// `.r` is scaled from a 375 × 812 logical-pixel frame.
  static const Size designSize = Size(375, 812);

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Obx(
        () => GetMaterialApp(
          title: Tr.appName.tr,
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode.value,
          translations: AppTranslations(),
          locale: settings.locale.value,
          fallbackLocale: AppTranslations.fallback,
          supportedLocales: const [
            AppTranslations.english,
            AppTranslations.bengali,
          ],
          // Without these, switching to bn_BD throws "No MaterialLocalizations
          // found" as soon as a Scaffold / AppBar / TabBar rebuilds.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
