import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/settings/settings_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../controllers/sign_in_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final settings = Get.find<SettingsController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: settings.toggleLocale,
                            child: Obx(
                              () => Text(
                                settings.locale.value.languageCode == 'bn'
                                    ? 'EN'
                                    : 'বাংলা',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => settings.setThemeMode(
                              Theme.of(context).brightness == Brightness.dark
                                  ? ThemeMode.light
                                  : ThemeMode.dark,
                            ),
                            icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const AppLogo(size: 40),
                    const SizedBox(height: 20),
                    Text(Tr.signInTitle.tr, style: text.headlineMedium),
                    const SizedBox(height: 24),
                    Obx(
                      () => TextFormField(
                        controller: controller.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: Tr.email.tr,
                          errorText: controller.emailError.value,
                        ),
                        validator: controller.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordCtrl,
                        obscureText: controller.obscure.value,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.submit(),
                        decoration: InputDecoration(
                          labelText: Tr.password.tr,
                          errorText: controller.passwordError.value,
                          suffixIcon: IconButton(
                            onPressed: controller.toggleObscure,
                            icon: Icon(
                              controller.obscure.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: controller.validatePassword,
                      ),
                    ),
                    Obx(() {
                      final err = controller.formError.value;
                      if (err == null) return const SizedBox(height: 20);
                      return Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          err,
                          style: text.bodySmall?.copyWith(color: c.criticalInk),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Obx(
                      () => FilledButton(
                        onPressed: controller.submitting.value
                            ? null
                            : controller.submit,
                        child: controller.submitting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(Tr.signIn.tr),
                      ),
                    ),
                    Align(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(Tr.forgotPassword.tr),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActivationHint(text: Tr.activationHint.tr),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivationHint extends StatelessWidget {
  const _ActivationHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.line),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
