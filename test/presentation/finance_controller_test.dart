import 'package:bizops360_mobile/data/repositories/fake_invoice_repository.dart';
import 'package:bizops360_mobile/domain/entities/invoice.dart';
import 'package:bizops360_mobile/presentation/finance/controllers/invoice_detail_controller.dart';
import 'package:bizops360_mobile/presentation/finance/controllers/invoices_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('outstanding sums the due amount of every unsettled invoice', () async {
    final c = InvoicesController(FakeInvoiceRepository());
    await c.load();

    final all = c.state.value.valueOrNull!;
    final expected = all
        .where((i) => !i.isSettled)
        .fold<num>(0, (sum, i) => sum + i.due);

    expect(c.outstanding, expected);
    expect(c.outstanding, greaterThan(0));
  });

  test('status filter narrows the visible list', () async {
    final c = InvoicesController(FakeInvoiceRepository());
    await c.load();
    final total = c.visible.length;

    c.toggleStatus(InvoiceStatus.paid);
    expect(c.visible.every((i) => i.status == InvoiceStatus.paid), isTrue);
    expect(c.visible.length, lessThan(total));

    c.toggleStatus(InvoiceStatus.paid); // clear
    expect(c.visible.length, total);
  });

  test(
    'recording a partial payment updates paid/due and stays partial',
    () async {
      final repo = FakeInvoiceRepository();
      final all = (await repo.invoices()).valueOrNull!;
      final unpaid = all.firstWhere((i) => i.status == InvoiceStatus.unpaid);
      final c = InvoiceDetailController(repo, unpaid.id);
      await c.reload();

      final ok = await c.recordPayment(amount: 1000, method: 'Cash');

      expect(ok, isTrue);
      final updated = c.state.value.valueOrNull!;
      expect(updated.paidAmount, 1000);
      expect(updated.status, InvoiceStatus.partial);
      expect(updated.payments, hasLength(1));
    },
  );

  test('a payment that clears the balance marks the invoice paid', () async {
    final repo = FakeInvoiceRepository();
    final all = (await repo.invoices()).valueOrNull!;
    final unpaid = all.firstWhere((i) => i.status == InvoiceStatus.unpaid);
    final c = InvoiceDetailController(repo, unpaid.id);
    await c.reload();

    await c.recordPayment(amount: unpaid.amount, method: 'Bank transfer');

    expect(c.state.value.valueOrNull!.status, InvoiceStatus.paid);
    expect(c.state.value.valueOrNull!.due, 0);
  });
}
