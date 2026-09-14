import '../../core/error/result.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import 'remote_guard.dart';

const Map<String, DocumentCategory> _categoryFromApi = {
  'nid': DocumentCategory.nid,
  'passport': DocumentCategory.passport,
  'contract': DocumentCategory.contract,
  'offer_letter': DocumentCategory.agreement,
  'certificate': DocumentCategory.certificate,
  'other': DocumentCategory.other,
};

String _sizeLabel(dynamic bytes) {
  final b = (bytes is num ? bytes : num.tryParse(bytes?.toString() ?? '')) ?? 0;
  if (b <= 0) return '';
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
  return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
}

DocumentItem _documentFromJson(Map<String, dynamic> json) {
  final employee = json['employee'];
  return DocumentItem(
    id: json['id'].toString(),
    name: json['title'] as String? ?? json['original_name'] as String? ?? '',
    category: _categoryFromApi[json['category']] ?? DocumentCategory.other,
    ownerType: DocumentOwnerType.employee,
    ownerName: employee is Map
        ? (employee['name'] as String? ?? 'Employee')
        : 'Employee',
    uploadedAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now(),
    expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    sizeLabel: _sizeLabel(json['size']),
  );
}

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._remote);

  final DocumentRemoteDataSource _remote;

  @override
  Future<Result<List<DocumentItem>>> list() {
    return guardRequest(
      () async =>
          (await _remote.list()).map(_documentFromJson).toList(growable: false),
    );
  }
}
