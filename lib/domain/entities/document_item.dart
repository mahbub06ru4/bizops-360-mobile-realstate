import 'package:equatable/equatable.dart';

enum DocumentCategory {
  passport,
  visa,
  ticket,
  contract,
  invoice,
  agreement,
  certificate,
  nid,
  other,
}

enum DocumentOwnerType { customer, employee, company }

class DocumentItem extends Equatable {
  const DocumentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.ownerType,
    required this.ownerName,
    required this.uploadedAt,
    this.expiresAt,
    this.sizeLabel,
  });

  final String id;
  final String name;
  final DocumentCategory category;
  final DocumentOwnerType ownerType;
  final String ownerName;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final String? sizeLabel;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get expiresSoon {
    final e = expiresAt;
    if (e == null || isExpired) return false;
    return e.difference(DateTime.now()).inDays <= 45;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    ownerType,
    ownerName,
    uploadedAt,
    expiresAt,
    sizeLabel,
  ];
}
