import 'package:get/get.dart';

import '../../../data/datasources/booking_remote_datasource.dart';
import '../../../data/datasources/finance_remote_datasource.dart';
import '../../../data/repositories/fake_invoice_repository.dart';
import '../../../data/repositories/invoice_repository_impl.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../controllers/invoice_detail_controller.dart';
import '../controllers/invoices_controller.dart';

/// Public so `BookingDetailScreen` can create an invoice without a full
/// `InvoicesBinding`.
void ensureInvoiceRepo() => registerRepo<InvoiceRepository>(
  (client) => InvoiceRepositoryImpl(
    FinanceRemoteDataSource(client),
    BookingRemoteDataSource(client),
  ),
  FakeInvoiceRepository.new,
);

class InvoicesBinding extends Bindings {
  @override
  void dependencies() {
    ensureInvoiceRepo();
    Get.lazyPut<InvoicesController>(() => InvoicesController(Get.find()));
  }
}

class InvoiceDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureInvoiceRepo();
    final arg = Get.arguments;
    final seed = arg is Invoice ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<InvoiceDetailController>(
      () => InvoiceDetailController(Get.find(), id, seed: seed),
    );
  }
}
