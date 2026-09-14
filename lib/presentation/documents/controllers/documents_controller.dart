import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/document_item.dart';
import '../../../domain/repositories/document_repository.dart';

class DocumentsController extends GetxController {
  DocumentsController(this._repo);

  final DocumentRepository _repo;

  final Rx<AsyncValue<List<DocumentItem>>> state =
      const AsyncValue<List<DocumentItem>>.loading().obs;
  final Rxn<DocumentCategory> category = Rxn<DocumentCategory>();
  final RxBool expiringOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.list()).fold(AsyncValue.data, AsyncValue.error);
  }

  List<DocumentItem> get visible {
    final all = state.value.valueOrNull ?? const [];
    return all.where((d) {
      final catOk = category.value == null || d.category == category.value;
      final expOk = !expiringOnly.value || d.expiresSoon || d.isExpired;
      return catOk && expOk;
    }).toList();
  }

  int get expiringCount => (state.value.valueOrNull ?? const [])
      .where((d) => d.expiresSoon || d.isExpired)
      .length;

  void toggleCategory(DocumentCategory c) =>
      category.value = category.value == c ? null : c;
}
