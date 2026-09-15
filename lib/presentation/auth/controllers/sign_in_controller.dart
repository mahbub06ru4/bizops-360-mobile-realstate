import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/error/failure.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/storage/kv_store.dart';
import '../../../domain/usecases/auth/continue_as_buyer_usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';

class SignInController extends GetxController {
  SignInController({
    required SignInUseCase signIn,
    required ContinueAsBuyerUseCase continueAsBuyer,
    required AuthController auth,
    required KvStore store,
  }) : _signIn = signIn,
       _continueAsBuyer = continueAsBuyer,
       _auth = auth,
       _store = store;

  final SignInUseCase _signIn;
  final ContinueAsBuyerUseCase _continueAsBuyer;
  final AuthController _auth;
  final KvStore _store;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool submitting = false.obs;
  final RxBool obscure = true.obs;
  final RxnString formError = RxnString();
  final RxnString emailError = RxnString();
  final RxnString passwordError = RxnString();

  @override
  void onInit() {
    super.onInit();
    emailCtrl.text = _store.lastEmail ?? '';
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  void toggleObscure() => obscure.toggle();

  String? validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return Tr.email.tr;
    if (!GetUtils.isEmail(value)) return Tr.email.tr;
    return null;
  }

  String? validatePassword(String? v) =>
      (v ?? '').isEmpty ? Tr.password.tr : null;

  Future<void> submit() async {
    _clearErrors();
    if (!(formKey.currentState?.validate() ?? false)) return;

    submitting.value = true;
    final email = emailCtrl.text.trim();
    final result = await _signIn(email: email, password: passwordCtrl.text);
    submitting.value = false;

    result.fold((user) {
      _store.lastEmail = email;
      _auth.setUser(user);
      unawaited(Get.offAllNamed<void>(Routes.shell));
    }, _applyFailure);
  }

  void _applyFailure(Failure failure) {
    if (failure is ValidationFailure) {
      emailError.value = failure.forField('email');
      passwordError.value = failure.forField('password');
      formError.value = emailError.value == null && passwordError.value == null
          ? failure.message
          : null;
    } else {
      formError.value = failure.message;
    }
  }

  /// "Continue as Buyer" — a demo-only entry point into the platform-level
  /// buyer persona (`docs/HANDOFF.md` Phase 2); no credentials involved.
  Future<void> continueAsBuyer() async {
    _clearErrors();
    submitting.value = true;
    final result = await _continueAsBuyer();
    submitting.value = false;
    result.fold((user) {
      _auth.setUser(user);
      unawaited(Get.offAllNamed<void>(Routes.buyerShell));
    }, _applyFailure);
  }

  void _clearErrors() {
    formError.value = null;
    emailError.value = null;
    passwordError.value = null;
  }
}
