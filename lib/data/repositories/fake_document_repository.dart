import '../../core/error/result.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repositories/document_repository.dart';

/// In-memory documents for UI-first development (`Env.useFakeData`).
class FakeDocumentRepository implements DocumentRepository {
  static DateTime _ago(int d) => DateTime.now().subtract(Duration(days: d));
  static DateTime _in(int d) => DateTime.now().add(Duration(days: d));

  static final _items = <DocumentItem>[
    DocumentItem(
      id: 'd1',
      name: 'Passport — Karim Rahman.pdf',
      category: DocumentCategory.passport,
      ownerType: DocumentOwnerType.customer,
      ownerName: 'Karim Rahman',
      uploadedAt: _ago(3),
      expiresAt: _in(20),
      sizeLabel: '1.2 MB',
    ),
    DocumentItem(
      id: 'd2',
      name: 'Schengen visa — Mizanur.pdf',
      category: DocumentCategory.visa,
      ownerType: DocumentOwnerType.customer,
      ownerName: 'Mizanur Rahman',
      uploadedAt: _ago(9),
      expiresAt: _in(120),
      sizeLabel: '640 KB',
    ),
    DocumentItem(
      id: 'd3',
      name: 'Invoice #2043.pdf',
      category: DocumentCategory.invoice,
      ownerType: DocumentOwnerType.customer,
      ownerName: 'Nusrat Jahan',
      uploadedAt: _ago(1),
      sizeLabel: '88 KB',
    ),
    DocumentItem(
      id: 'd4',
      name: 'Employment contract — Rahim Uddin.pdf',
      category: DocumentCategory.contract,
      ownerType: DocumentOwnerType.employee,
      ownerName: 'Rahim Uddin',
      uploadedAt: _ago(200),
      sizeLabel: '410 KB',
    ),
    DocumentItem(
      id: 'd5',
      name: 'NID — Sadia Islam.jpg',
      category: DocumentCategory.nid,
      ownerType: DocumentOwnerType.employee,
      ownerName: 'Sadia Islam',
      uploadedAt: _ago(60),
      sizeLabel: '2.1 MB',
    ),
    DocumentItem(
      id: 'd6',
      name: 'IATA certificate.pdf',
      category: DocumentCategory.certificate,
      ownerType: DocumentOwnerType.company,
      ownerName: 'Wanderlust Travel',
      uploadedAt: _ago(400),
      expiresAt: _ago(5),
      sizeLabel: '300 KB',
    ),
  ];

  @override
  Future<Result<List<DocumentItem>>> list() => Future.delayed(
    const Duration(milliseconds: 300),
    () => Result.ok(List.unmodifiable(_items)),
  );
}
