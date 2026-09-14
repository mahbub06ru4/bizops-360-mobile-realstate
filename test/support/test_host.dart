import 'package:bizops360_mobile/app/app.dart';
import 'package:bizops360_mobile/core/localization/app_translations.dart';
import 'package:bizops360_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Pumps [child] inside the real theme + `ScreenUtilInit` (so design tokens
/// that call `.r` / `.sp` resolve) + GetX translations, in light or dark.
Future<void> pumpInHost(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) {
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: BizOpsApp.designSize,
      builder: (context, _) => GetMaterialApp(
        theme: brightness == Brightness.light
            ? AppTheme.light()
            : AppTheme.dark(),
        locale: AppTranslations.english,
        translations: AppTranslations(),
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}
