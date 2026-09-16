import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(Tr.registerTitle.tr)),
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
                    Text(Tr.registerSubtitle.tr, style: text.bodyMedium),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller.companyNameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: Tr.registerCompanyName.tr,
                      ),
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => AppDropdown<String>(
                        label: Tr.registerIndustry.tr,
                        value: controller.industry.value,
                        items: [
                          for (final option in kIndustryOptions)
                            AppDropdownItem(option.code, option.labelKey.tr),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.industry.value = v;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.ownerNameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: Tr.registerOwnerName.tr,
                      ),
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.ownerEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: Tr.registerOwnerEmail.tr,
                      ),
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => TextFormField(
                        controller: controller.ownerPasswordCtrl,
                        obscureText: controller.obscurePassword.value,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: Tr.registerPassword.tr,
                          suffixIcon: IconButton(
                            onPressed: controller.toggleObscurePassword,
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: controller.validatePassword,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.ownerPasswordConfirmCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.submit(),
                      decoration: InputDecoration(
                        labelText: Tr.registerPasswordConfirm.tr,
                      ),
                      validator: controller.validateConfirmPassword,
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
                            : Text(Tr.registerSubmit.tr),
                      ),
                    ),
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
