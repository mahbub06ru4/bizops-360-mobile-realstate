import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/invoice.dart';

extension InvoiceStatusDisplay on InvoiceStatus {
  String get labelKey => switch (this) {
    InvoiceStatus.unpaid => Tr.invStatusUnpaid,
    InvoiceStatus.partial => Tr.invStatusPartial,
    InvoiceStatus.paid => Tr.invStatusPaid,
    InvoiceStatus.overdue => Tr.invStatusOverdue,
    InvoiceStatus.cancelled => Tr.invStatusCancelled,
  };

  ChipTone get tone => switch (this) {
    InvoiceStatus.unpaid => ChipTone.neutral,
    InvoiceStatus.partial => ChipTone.signal,
    InvoiceStatus.paid => ChipTone.brand,
    InvoiceStatus.overdue => ChipTone.critical,
    InvoiceStatus.cancelled => ChipTone.neutral,
  };
}
