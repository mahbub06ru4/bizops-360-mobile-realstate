import 'package:equatable/equatable.dart';

/// Mirrors `BranchResource`.
class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.phone,
    this.email,
    this.isHeadOffice = false,
  });

  final String id;
  final String name;
  final String code;
  final String? address;
  final String? phone;
  final String? email;
  final bool isHeadOffice;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    address,
    phone,
    email,
    isHeadOffice,
  ];
}

class BranchInput extends Equatable {
  const BranchInput({
    required this.name,
    required this.code,
    this.address,
    this.phone,
    this.email,
    this.isHeadOffice = false,
  });

  final String name;
  final String code;
  final String? address;
  final String? phone;
  final String? email;
  final bool isHeadOffice;

  @override
  List<Object?> get props => [name, code, address, phone, email, isHeadOffice];
}
