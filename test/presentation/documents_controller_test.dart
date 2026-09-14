import 'package:bizops360_mobile/data/repositories/fake_document_repository.dart';
import 'package:bizops360_mobile/domain/entities/document_item.dart';
import 'package:bizops360_mobile/presentation/documents/controllers/documents_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category filter and expiring-only filter compose', () async {
    final c = DocumentsController(FakeDocumentRepository());
    await c.load();
    final total = c.visible.length;

    c.toggleCategory(DocumentCategory.passport);
    expect(
      c.visible.every((d) => d.category == DocumentCategory.passport),
      isTrue,
    );

    c.toggleCategory(DocumentCategory.passport); // clear
    c.expiringOnly.value = true;
    expect(c.visible.every((d) => d.expiresSoon || d.isExpired), isTrue);
    expect(c.visible.length, lessThan(total));
    expect(c.expiringCount, c.visible.length);
  });
}
