import 'package:get/get.dart';

import '../../../data/datasources/document_remote_datasource.dart';
import '../../../data/repositories/document_repository_impl.dart';
import '../../../data/repositories/fake_document_repository.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../domain/repositories/document_repository.dart';
import '../controllers/documents_controller.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    registerRepo<DocumentRepository>(
      (client) => DocumentRepositoryImpl(DocumentRemoteDataSource(client)),
      FakeDocumentRepository.new,
    );
    Get.lazyPut<DocumentsController>(() => DocumentsController(Get.find()));
  }
}
