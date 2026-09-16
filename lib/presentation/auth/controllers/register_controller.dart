import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/error/failure.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../domain/usecases/auth/register_usecase.dart';

/// One industry code per `RegisterUseCase.industry` — this app defaults to
/// `real_estate` (its own vertical) but the backend accepts the others too,
/// so the field is not hardcoded away (roadmap §7 Phase 3).
class IndustryOption {
  const IndustryOption(this.code, this.labelKey);

  final String code;
  final String labelKey;
}

const List<IndustryOption> kIndustryOptions = [
  IndustryOption('real_estate', Tr.industryRealEstate),
  IndustryOption('travel', Tr.industryTravel),
  IndustryOption('consultancy', Tr.industryConsultancy),
];

class RegisterController extends GetxController {
  RegisterController({
    required RegisterUseCase register,
    required AuthController auth,
  }) : _register = register,
       _auth = auth;

  final RegisterUseCase _register;
  final AuthController _auth;

  final formKey = GlobalKey<FormState>();
  final companyNameCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final ownerEmailCtrl = TextEditingController();
  final ownerPasswordCtrl = TextEditingController();
  final ownerPasswordConfirmCtrl = TextEditingController();

  final Rx<String> industry = kIndustryOptions.first.code.obs;
  final RxBool submitting = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString formError = RxnString();

  @override
  void onClose() {
    companyNameCtrl.dispose();
    ownerNameCtrl.dispose();
    ownerEmailCtrl.dispose();
    ownerPasswordCtrl.dispose();
    ownerPasswordConfirmCtrl.dispose();
    super.onClose();
  }

  void toggleObscurePassword() => obscurePassword.toggle();

  String? validateRequired(String? v) =>
      (v ?? '').trim().isEmpty ? Tr.registerRequired.tr : null;

  String? validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return Tr.registerRequired.tr;
    if (!GetUtils.isEmail(value)) return Tr.email.tr;
    return null;
  }

  String? validatePassword(String? v) {
    if ((v ?? '').isEmpty) return Tr.registerRequired.tr;
    if (v!.length < 8) return Tr.registerPasswordTooShort.tr;
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if ((v ?? '').isEmpty) return Tr.registerRequired.tr;
    if (v != ownerPasswordCtrl.text) return Tr.registerPasswordMismatch.tr;
    return null;
  }

  Future<void> submit() async {
    formError.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;

    submitting.value = true;
    final result = await _register(
      companyName: companyNameCtrl.text.trim(),
      industry: industry.value,
      ownerName: ownerNameCtrl.text.trim(),
      ownerEmail: ownerEmailCtrl.text.trim(),
      ownerPassword: ownerPasswordCtrl.text,
      ownerPasswordConfirmation: ownerPasswordConfirmCtrl.text,
    );
    submitting.value = false;

    result.fold(
      (user) {
        _auth.setUser(user);
        unawaited(Get.offNamed<void>(Routes.planSelection));
      },
      (failure) {
        formError.value = failure is ValidationFailure
            ? failure.message
            : failure.message;
      },
    );
  }
}
