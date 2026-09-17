import '../../domain/entities/branch.dart';

/// Verified against `BranchResource` / `BranchRequest`.
Branch branchFromJson(Map<String, dynamic> json) => Branch(
  id: json['id'].toString(),
  name: json['name'] as String? ?? '',
  code: json['code'] as String? ?? '',
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  isHeadOffice: json['is_head_office'] as bool? ?? false,
);

Map<String, dynamic> branchInputToJson(BranchInput input) => {
  'name': input.name,
  'code': input.code,
  if (input.address != null) 'address': input.address,
  if (input.phone != null) 'phone': input.phone,
  if (input.email != null) 'email': input.email,
  'is_head_office': input.isHeadOffice,
};
