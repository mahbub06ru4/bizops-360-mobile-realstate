import '../../core/error/result.dart';
import '../entities/document_item.dart';

abstract interface class DocumentRepository {
  /// All documents the current user may see, newest first.
  Future<Result<List<DocumentItem>>> list();
}
