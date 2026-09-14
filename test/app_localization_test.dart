import 'package:bizops360_mobile/core/localization/app_translations.dart';
import 'package:bizops360_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Regression: switching to bn_BD used to crash with "No MaterialLocalizations
/// found" because the app shipped no `localizationsDelegates`.
void main() {
  testWidgets('a Scaffold + AppBar + TabBar builds under bn_BD', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => GetMaterialApp(
          locale: AppTranslations.bengali,
          fallbackLocale: AppTranslations.english,
          translations: AppTranslations(),
          supportedLocales: const [
            AppTranslations.english,
            AppTranslations.bengali,
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(),
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('বুকিং'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'ছুটি'),
                    Tab(text: 'খরচ'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [SizedBox.shrink(), SizedBox.shrink()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      Localizations.localeOf(tester.element(find.byType(Scaffold))),
      AppTranslations.bengali,
    );
    expect(find.text('ছুটি'), findsOneWidget);
  });
}
