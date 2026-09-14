import 'package:flutter/material.dart';

import '../../core/localization/translation_keys.dart';
import '../../domain/entities/document_item.dart';

extension DocumentCategoryDisplay on DocumentCategory {
  String get labelKey => switch (this) {
    DocumentCategory.passport => Tr.docCatPassport,
    DocumentCategory.visa => Tr.docCatVisa,
    DocumentCategory.ticket => Tr.docCatTicket,
    DocumentCategory.contract => Tr.docCatContract,
    DocumentCategory.invoice => Tr.docCatInvoice,
    DocumentCategory.agreement => Tr.docCatAgreement,
    DocumentCategory.certificate => Tr.docCatCertificate,
    DocumentCategory.nid => Tr.docCatNid,
    DocumentCategory.other => Tr.docCatOther,
  };

  IconData get icon => switch (this) {
    DocumentCategory.passport => Icons.badge_outlined,
    DocumentCategory.visa => Icons.approval_outlined,
    DocumentCategory.ticket => Icons.confirmation_number_outlined,
    DocumentCategory.contract => Icons.handshake_outlined,
    DocumentCategory.invoice => Icons.receipt_long_outlined,
    DocumentCategory.agreement => Icons.description_outlined,
    DocumentCategory.certificate => Icons.workspace_premium_outlined,
    DocumentCategory.nid => Icons.credit_card_outlined,
    DocumentCategory.other => Icons.insert_drive_file_outlined,
  };
}
