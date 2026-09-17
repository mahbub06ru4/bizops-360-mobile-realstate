import 'package:get/get.dart';

import '../../../core/error/failure.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/state/async_value.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/designation.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/branch_repository.dart';
import '../../../domain/repositories/department_repository.dart';
import '../../../domain/repositories/designation_repository.dart';
import '../../../domain/repositories/employee_repository.dart';

/// Create/edit form for one employee. [existing] is null for create.
class EmployeeFormController extends GetxController {
  EmployeeFormController(
    this._employees,
    this._branches,
    this._departments,
    this._designations, {
    this.existing,
  });

  final EmployeeRepository _employees;
  final BranchRepository _branches;
  final DepartmentRepository _departments;
  final DesignationRepository _designations;
  final Employee? existing;

  bool get isEdit => existing != null;

  final Rx<AsyncValue<EmployeeFormLookups>> lookups =
      const AsyncValue<EmployeeFormLookups>.loading().obs;
  final RxBool saving = false.obs;
  final Rxn<ValidationFailure> validation = Rxn<ValidationFailure>();

  final RxString employeeCode = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final Rx<DateTime> hireDate = DateTime.now().obs;
  final RxnString branchId = RxnString();
  final RxnString departmentId = RxnString();
  final RxnString designationId = RxnString();

  @override
  void onInit() {
    super.onInit();
    final e = existing;
    if (e != null) {
      employeeCode.value = e.employeeCode;
      firstName.value = e.firstName;
      lastName.value = e.lastName;
      email.value = e.email ?? '';
      phone.value = e.phone ?? '';
      hireDate.value = e.hireDate ?? DateTime.now();
      branchId.value = e.branchId;
      departmentId.value = e.departmentId;
      designationId.value = e.designationId;
    }
    loadLookups();
  }

  Future<void> loadLookups() async {
    lookups.value = const AsyncValue.loading();
    final branchesResult = await _branches.branches();
    final departmentsResult = await _departments.departments();
    final designationsResult = await _designations.designations();

    final failure =
        branchesResult.failureOrNull ??
        departmentsResult.failureOrNull ??
        designationsResult.failureOrNull;
    if (failure != null) {
      lookups.value = AsyncValue.error(failure);
      return;
    }

    lookups.value = AsyncValue.data(
      EmployeeFormLookups(
        branches: branchesResult.valueOrNull ?? const [],
        departments: departmentsResult.valueOrNull ?? const [],
        designations: designationsResult.valueOrNull ?? const [],
      ),
    );
  }

  Future<bool> save() async {
    validation.value = null;
    if (employeeCode.value.trim().isEmpty ||
        firstName.value.trim().isEmpty ||
        lastName.value.trim().isEmpty) {
      AppSnackbar.error(Tr.formRequiredFields.tr);
      return false;
    }

    saving.value = true;
    final input = EmployeeInput(
      employeeCode: employeeCode.value.trim(),
      firstName: firstName.value.trim(),
      lastName: lastName.value.trim(),
      hireDate: hireDate.value,
      email: email.value.trim().isEmpty ? null : email.value.trim(),
      phone: phone.value.trim().isEmpty ? null : phone.value.trim(),
      branchId: branchId.value,
      departmentId: departmentId.value,
      designationId: designationId.value,
    );

    final result = isEdit
        ? await _employees.updateEmployee(existing!.id, input)
        : await _employees.createEmployee(input);
    saving.value = false;

    return result.fold(
      (_) {
        AppSnackbar.show(
          isEdit ? Tr.empUpdated.tr : Tr.empCreated.tr,
          tone: FeedbackTone.success,
        );
        return true;
      },
      (failure) {
        if (failure is ValidationFailure) validation.value = failure;
        AppSnackbar.error(failure.message);
        return false;
      },
    );
  }
}

class EmployeeFormLookups {
  const EmployeeFormLookups({
    required this.branches,
    required this.departments,
    required this.designations,
  });

  final List<Branch> branches;
  final List<Department> departments;
  final List<Designation> designations;
}
